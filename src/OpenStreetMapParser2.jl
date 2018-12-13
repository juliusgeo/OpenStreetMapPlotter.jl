module OpenStreetMapParser2
using LightXML
using HTTP
using Winston
using Statistics
include("structs.jl")
include("styles.jl")

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

function plot_ways(way_arr::Array{Way}; bbox::Tuple = nothing, width::Int64=500, roads_only::Bool=false)
	minlon = bbox[1]
	maxlon = bbox[3]
	minlat = bbox[2]
	maxlat = bbox[4]
	c_adj = cosd((minlat + maxlat) / 2)
    range_y = maxlat - minlat
    range_x = maxlon - minlon
	aspect_ratio = range_x * c_adj / range_y

	fignum = Winston.figure(name="OpenStreetMap Plot", width=width, height=round(Int, width/aspect_ratio))
	p = FramedPlot()
	draw_later = []
	for way in way_arr
		style=get_way_style(way.tags)
		if way.nodes[1] == way.nodes[end]
			style.polygon = true
		else
			style.polygon = false
		end
		if style.polygon == true
			split = findmax([i.x for i in way.nodes])[2]
			start = findmin([i.x for i in way.nodes])[2]
			topside = way.nodes[1:split]
			bottomside = way.nodes[split:end]
			f = FillBetween([i.x for i in topside], [i.y for i in topside], [i.x for i in bottomside], [i.y for i in bottomside], fillcolor = style.color, linewidth=style.width)
			Winston.add(p, f)
		elseif haskey(way.tags, "highway")
			if way.tags["highway"] in ["motorway", "trunk", "primary", "secondary", "tertiary"]
				push!(draw_later, way)
			else
				plot(p, [i.x for i in way.nodes], [i.y for i in way.nodes], style.spec, color=style.color, linewidth=style.width, xrange=(minlon, maxlon), yrange=(minlat, maxlat))
			end
		elseif roads_only == false
    		plot(p, [i.x for i in way.nodes], [i.y for i in way.nodes], style.spec, color=style.color, linewidth=style.width, xrange=(minlon, maxlon), yrange=(minlat, maxlat))
    	end
    end
    for way in draw_later
    	style=get_way_style(way.tags)
    	if way.nodes[1] == way.nodes[end]
			style.polygon = true
		else
			style.polygon = false
		end
    	plot(p, [i.x for i in way.nodes], [i.y for i in way.nodes], style.spec, color=style.color, linewidth=style.width, xrange=(minlon, maxlon), yrange=(minlat, maxlat))
    end
    #savefig(p, "map_out.svg", width=width, height=round(Int, width/aspect_ratio))
    display(p)
end
function sort_counterclockwise(nodes::Array{Node})
	center = center_of_points(nodes)
	return sort(nodes, lt=(a, b)->!is_less(a, b, center))
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
