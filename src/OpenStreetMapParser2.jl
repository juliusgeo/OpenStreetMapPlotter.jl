module OpenStreetMapParser2
using LightXML
using HTTP
using Winston

include("dicts.jl")

struct Node
    x::Float64
    y::Float64
    id::String
end

struct Style
	color::UInt
	width::Int
	spec::String
end

mutable struct Way
    id::String
    visible::Bool
    version::Int
    changeset::String
    timestamp::String
    user::String
    uid::String
    nodes::Array{Node}
    tags::Dict
    Way() = new()
end

mutable struct Relation
    id::String
    visible::Bool
    version::Int
    changeset::String
    timestamp::String
    user::String
    uid::String
    members::Array{Any}
    tags::Dict
    Relation() = new()
end

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
    return way_arr
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

function plot_ways(way_arr::Array{Way}, bbox::Tuple; width::Int64=500, roads_only::Bool=false)
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
	for way in way_arr
		style=get_way_style(way.tags)
    	plot(p, [i.x for i in way.nodes], [i.y for i in way.nodes], style.spec, color=style.color, linewidth=style.width, xrange=(minlon, maxlon), yrange=(minlat, maxlat))
    end
    display(p)
end



highway_styles = Dict(
	"motorway" => Style(0x0015ff, 6, "-"), #bright blue
	"trunk" => Style(0x9000ff, 5, "-"), #bright purple
	"primary" => Style(0xff6868, 5, "-"), #orange
	"secondary" => Style(0xfc4b4b, 4, "-"), #orange-ish red
	"tertiary" => Style(0xfc3232, 3, "-"), #red
	"unclassified" => Style(0xF1EEE8, 2, "-"),
	"residential" => Style(0xF1EEE8, 2, "-"),
	"service" => Style(0x007CFF, 1, "-"),
	"motorway_link" => Style(0xe891a1, 2, "-"),
	"trunk_link" => Style(0xf9b29c, 2, "-"),
	"primary_link" => Style(0xFCD6A4, 2, "-"),
	"secondary_link" => Style(0xF6F9BE, 2, "-"),
	"tertiary_link" => Style(0xFEFEFE, 2, "-"),
	"living_street" => Style(0xF1EEE8, 2, "-"),
	"pedestrian" => Style(0x888888, 2, "-"),
	"track" => Style(0x909090, 1, ":"),
	"bus_guideway" => Style(0x989898, 1, ":"),
	"escape" => Style(0xA0A0A0, 1, ":"),
	"raceway" => Style(0xA8A8A8, 1, ":"),
	"road" => Style(0xA9A9A9, 1, ":"),
	"footway" => Style(0xB0B0B0, 1, ":"),
	"bridleway" => Style(0xB8B8B8, 1, ":"),
	"steps" => Style(0xBEBEBE, 1, ":"),
	"path" => Style(0xC0C0C0, 1, ":")
)
building_styles = Dict(
	"yes" => Style(0xe891a1, 1, "-"),
	"house" => Style(0x91f2ce, 1, "-"),
	"residential" => Style(0x91f2ce, 1, "-"),
	"garage" => Style(0x91f2ce, 1, "-"),
	"apartment" => Style(0x91f2ce, 1, "-"), #all residential stuff is greenish
	"hut" => Style(0xe891a1, 1, "-"),
	"industrial" => Style(0x876d6c, 1, "-"),
	"detached" => Style(0xe891a1, 1, "-"),
	"shed" => Style(0x876d6c, 1, "-"),
	"commercial" => Style(0xfcb5b3, 1, "-"),
	"terrace" => Style(0xe891a1, 1, "-"),
	"garages" => Style(0xe891a1, 1, "-"),
	"school" => Style(0xb2effc, 1, "-"), #schools are blue
	"construction" => Style(0xf2d2d8, 1, "-"),
)
waterway_styles = Dict(
	"stream" => Style(0x609af7, 3, "-"),
	"ditch" => Style(0x609af7, 1, "-"),
	"river" => Style(0x609af7, 5, "-"),
	"drain" => Style(0x609af7, 1, "-"),
	"riverbank" => Style(0x609af7, 1, "-"),
	"canal" => Style(0x609af7, 1, "-"),
	"other" => Style(0x609af7, 1, "-"),
)
leisure_styles = Dict(
	"pitch" => Style(0x30bc0d, 2, "-"),
	"swimming_pool" => Style(0x609af7, 2, "-"),
	"park" => Style(0x30bc0d, 2, "-"),
	"playground" => Style(0x30bc0d, 1, "-"),
	"garden" => Style(0x30bc0d, 1, "-"),
	"sports_centre" => Style(0x30bc0d, 1, "-"),
	"other" => Style(0x30bc0d, 1, "-"),
)
tag2style = Dict(
	"waterway" => waterway_styles,
	"building" => building_styles,
	"highway" => highway_styles,
	"leisure" => leisure_styles,
)
function get_way_style(tags::Dict)
	for tag in ["waterway", "building", "highway", "leisure"]
		if haskey(tags, tag)
			if haskey(tag2style[tag], tags[tag])
				return tag2style[tag][tags[tag]]
			end
		end
	end
	return Style(0x808080, 1, "-")
end
export open_file, open_bbox, parse_nodes, parse_ways, parse_relations, plot_ways, Node, Tag, Way

end
