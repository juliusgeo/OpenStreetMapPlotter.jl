module OpenStreetMapPlotter
using LightXML
using HTTP
using Winston

include("structs.jl")
include("styles.jl")
include("MapCSSParser.jl")
function open_file(filepath::String)
	xdoc = parse_file(filepath)
	xroot = root(xdoc)  # an instance of XMLElement
	return xroot
end

function open_bbox(bbox::Tuple)
	minlon = bbox[1]
	maxlon = bbox[3]
	minlat = bbox[2]
	maxlat = bbox[4]
	url = "http://overpass-api.de/api/map?bbox=$(minlon),$(minlat),$(maxlon),$(maxlat)"
	r = HTTP.request("GET", url)
	return root(parse_string(String(r.body)))
end

function parse_nodes(xroot::XMLElement)
    node_arr = Node[]
    for node in xroot["node"]
        id = attribute(node, "id")
        lat = parse(Float64, attribute(node, "lat"))
        lon = parse(Float64, attribute(node, "lon"))
        push!(node_arr, Node(lon, lat, id))
    end
    return node_arr
end

function find_node(id::String, node_arr::Array{Node})
    return node_arr[findfirst(x -> x.id == id, node_arr)]
end

function find_way(id::String, way_arr::Array{Way})
	try
    	return way_arr[findfirst(x -> x.id == id, way_arr)]
    catch
    	return false
    end
end
function parse_ways(xroot::XMLElement)
    way_arr = Way[]
    node_arr = parse_nodes(xroot)
    for way in xroot["way"]
        cur_way = Way()
        cur_way.id = attribute(way, "id")
        cur_way.visible = attribute(way, "visible") == "true"
        cur_way.version = parse(Int, attribute(way, "version"))
        cur_way.changeset = attribute(way, "changeset")
        cur_way.timestamp = attribute(way, "timestamp")
        cur_way.user = attribute(way, "user")
        cur_way.uid = attribute(way, "uid")
        cur_way.nodes = []
        for node in way["nd"]
            push!(cur_way.nodes, find_node(attribute(node, "ref"), node_arr))
        end
        cur_way.tags = Dict()
        for tag in way["tag"]
        	cur_way.tags[attribute(tag, "k")] = attribute(tag, "v")
        end
        push!(way_arr, cur_way)
    end
    bounds = xroot["bounds"][1]
    bbox = (parse(Float64, attribute(bounds, "minlon")), parse(Float64, attribute(bounds, "minlat")), parse(Float64, attribute(bounds, "maxlon")), parse(Float64, attribute(bounds, "maxlat")))
    return way_arr, bbox
end

function parse_relations(xroot::XMLElement, way_arr::Array{Way}, node_arr::Array{Node})
	rel_arr = []
    for rel in xroot["relation"]
        cur_rel = Relation()
        cur_rel.id = attribute(rel, "id")
        cur_rel.visible = lowercase(attribute(rel, "visible")) == "true"
        cur_rel.version = parse(Int, attribute(rel, "version"))
        cur_rel.changeset = attribute(rel, "changeset")
        cur_rel.timestamp = attribute(rel, "timestamp")
        cur_rel.user = attribute(rel, "user")
        cur_rel.uid = attribute(rel, "uid")
        cur_rel.members = []
        for member in rel["member"]
        	ref = attribute(member, "ref")
        	if attribute(member, "type") == "node"
            	push!(cur_rel.members, find_node(ref, node_arr))
            elseif attribute(member, "type") == "way"
            	try
            		temp_way = find_way(ref, way_arr)
            		if temp_way != false
            			push!(cur_rel.members, temp_way)
            		end
            	catch
            		continue
            	end
            end
        end
        cur_rel.tags = Dict()
        for tag in rel["tag"]
            cur_rel.tags[attribute(tag, "k")] = attribute(tag, "v")
        end
        push!(rel_arr, cur_rel)
    end
    return rel_arr
end

function plot_ways(way_arr::Array{Way}, bbox::Tuple; width::Int64=900, css_file_name::String="")
	minlon = bbox[1]
	maxlon = bbox[3]
	minlat = bbox[2]
	maxlat = bbox[4]
	c_adj = cosd((minlat + maxlat) / 2)
    range_y = maxlat - minlat
    range_x = maxlon - minlon
	aspect_ratio = range_x * c_adj / range_y
	fignum = Winston.figure(name="OpenStreetMap Plot", width=width, height=round(Int, width/aspect_ratio))
	p = FramedPlot(xrange = (minlon, maxlon), yrange = (minlat, maxlat))
	p.attr[:gutter] = 0
	p.attr[:title_style][:fontsize] = 1
	p.x1.attr[:ticklabels_style][:fontsize] = 1
	p.y1.attr[:ticklabels_style][:fontsize] = 1
	p.x1.attr[:draw_subticks] = true
	p.y1.attr[:draw_subticks] = true
	p.x1.attr[:ticks] = 10
	p.y1.attr[:ticks] = 10
	Winston._winston_config.defaults["fontsize_min"] = ".1"
	layers = Vector{Way}[[],[],[],[],[],[],[],[],[],[],[]]
	draw_later = []
	cascade = []
	if css_file_name != ""
		cascade = parse_css(css_file_name)
	end 
	for way in way_arr
		if haskey(way.tags, "layer")
			l = tryparse(Int, way.tags["layer"])
			if l == nothing
				println("invalid layer tag")
			else
				push!(layers[l+6], way)
			end
		end
		if haskey(way.tags, "highway")
				if way.tags["highway"] in ["motorway", "trunk", "primary", "secondary", "tertiary"]
					push!(layers[8], way)
				else
					push!(layers[7], way)
				end
		else
			push!(layers[6], way)
		end
	end
	labels = []
	for layer in layers
		for way in layer
			style=get_way_style(way.tags, cascade)
			if style == nothing
				continue
			end
			if way.nodes[1] == way.nodes[end]
				style["is_polygon"] = true
			else
				style["is_polygon"] = false
			end
			if haskey(style, "text")
				for i in keys(way.tags)
					if occursin(i, style["text"])
						c = center_of_points(way.nodes)
						c = ((c[1]-minlon)/range_x, (c[2]-minlat)/range_y)
						cur_label = PlotLabel(c[1], c[2], replace(way.tags[i], "&"=>"&amp;"), fontsize = style["font-size"])
						push!(labels, cur_label)
						break
					end
				end
			end
			f = nothing
			if style["is_polygon"] == true
				split = split_polygon(way.nodes)
				topside = way.nodes[1:split]
				bottomside = way.nodes[split:end]
				f = FillBetween([i.x for i in topside], [i.y for i in topside], [i.x for i in bottomside], [i.y for i in bottomside], fillcolor = style["color"], linewidth=style["width"])
			else
				f = Curve([i.x for i in way.nodes], [i.y for i in way.nodes], color=style["color"], linewidth=style["width"])
			end
	    	if f != nothing
	    		Winston.add(p, f)
	    	end
		end 
	end
	println(labels)
	for label in labels
		Winston.add(p, label)
	end
    display(p)
end
function split_polygon(nodes::Array{Node})
	return findmax([i.x for i in nodes])[2]
end
function sort_counterclockwise(nodes::Array{Node})
	center = center_of_points(nodes)
	return sort(nodes, lt=(a, b)->!is_less(a, b, center))
end
#taken from here: https://rosettacode.org/wiki/Shoelace_formula_for_polygonal_area#Julia
shoelacearea(x, y) = abs(sum(i * j for (i, j) in zip(x, append!(y[2:end], y[1]))) - sum(i * j for (i, j) in zip(append!(x[2:end], x[1]), y))) / 2
function get_area(nodes::Array{Node})
	x = [i.x for i in nodes]
	y = [i.y for i in nodes]
	return shoelacearea(x, y)
end
function is_less(a, b, center)
	if a.x-center[1] >= 0 && b.x-center[1] < 0
		return true
	elseif a.x -center[1] == 0 && b.x-center[1] == 0
		return a.y >b.y
	end
	det = (a.x - center[1]) * (b.y - center[2]) - (b.x - center[2]) * (a.y - center[2])
	if det < 0
		return true
	elseif det > 0 
		return false
	end
	d1 = (a.x - center[1]) * (a.x - center[1]) + (a.y - center[2]) * (a.y - center[2])
	d2 = (b.x - center[1]) * (b.x - center[1]) + (b.y - center[2]) * (b.y - center[2])
	return d1 > d2
end
function mean(array::AbstractArray)
	return sum(array)/length(array)
end
function center_of_points(nodes::Array{Node})
	return (mean([i.x for i in nodes]), mean([i.y for i in nodes]))
end
function save_json(way_arr::Array{Way}, filepath::String)
	f=open(filepath, "w")
	write(f, "{\n\"type\": \"FeatureCollection\",\n\"features\": [\n")
	flags = [true, true, true]
	for way in way_arr
		if flags[1] == true
			flags[1]=false
		else
			write(f, ",\n")
		end
		write(f, "{ \"type\": \"Feature\", \"properties\": {")
		flags[1] = false
		flags[2] = true
		for key in keys(way.tags)
			key = key
			val = way.tags[key]
			if flags[2] == true
				flags[2] = false
			else
				write(f, ",")
			end
			if in('"', val)
				write(f, "\"$key\":\"$(replace(val, r"\"" => "\\\""))\"")
			else
				write(f, "\"$key\":\"$val\"")
			end
		end
		startarraystr = ""
		endarraystr = ""
		sorted_arr = []
		if way.nodes[1] == way.nodes[end]
			write(f, "}, \"geometry\": { \"type\": \"Polygon\", \"coordinates\":")
			startarraystr = "[ ["
			endarraystr = "]] }}\n"
			sorted_arr = sort_counterclockwise(way.nodes)
			sorted_arr = vcat(sorted_arr, sorted_arr[1])
		elseif length(way.nodes) == 1
			write(f, "}, \"geometry\": { \"type\": \"Point\", \"coordinates\":")
			startarraystr = ""
			endarraystr = "}}\n"
			sorted_arr = way.nodes
		else
			write(f, "}, \"geometry\": { \"type\": \"LineString\", \"coordinates\":")
			startarraystr = "["
			endarraystr = "] }}\n"
			sorted_arr = sort_counterclockwise(way.nodes)
		end
		write(f, startarraystr)
		flags[3]=true
		
		for coord in sorted_arr
			lon = coord.x
			lat = coord.y
			if flags[3] == true
				flags[3] = false
			else
				write(f, ", ")
			end
			flags[3] = false
			write(f, "[ $lon, $lat]")
		end
		write(f, endarraystr)
	end
	
	write(f, "\n]\n}")
	close(f)
end
export open_file, open_bbox, parse_nodes, parse_ways, parse_relations, plot_ways, save_json, Node, Tag, Way, highway_styles, building_styles, waterway_styles


end
