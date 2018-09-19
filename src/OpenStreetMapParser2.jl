module OpenStreetMapParser2
using LightXML


struct Node
    x::Float64
    y::Float64
    id::String
end

struct Tag
    key::String
    val::String
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
    tags::Array{Tag}
    Way() = new()
end


function open_file(filepath::String)
	xdoc = parse_file("map.osm")
	xroot = root(xdoc)  # an instance of XMLElement
	return xroot
end

function parse_nodes(xroot::XMLElement)
    node_arr = Node[]
    for node in xroot["node"]
        id = attribute(node, "id")
        lat = parse(Float64, attribute(node, "lat"))
        lon = parse(Float64, attribute(node, "lon"))
        push!(node_arr, Node(lat, lon, id))
    end
    return node_arr
end

function find_node(id::String, node_arr::Array{Node})
    return node_arr[findfirst(x -> x.id == "37021436", node_arr)]
end

function parse_ways(xroot::XMLElement)
    way_arr = []
    node_arr = parse_nodes(xroot)
    for way in xroot["way"]  # c is an instance of XMLNode
        cur_way = Way()
        cur_way.id = attribute(way, "id")
        cur_way.visible = lowercase(attribute(way, "visible")) == "true"
        cur_way.version = parse(Int, attribute(way, "version"))
        cur_way.changeset = attribute(way, "changeset")
        cur_way.timestamp = attribute(way, "timestamp")
        cur_way.user = attribute(way, "user")
        cur_way.uid = attribute(way, "uid")
        cur_way.nodes = []
        for node in way["nd"]
            push!(cur_way.nodes, find_node(attribute(node, "ref"), node_arr))
        end
        cur_way.tags = []
        for tag in way["tag"]
            push!(cur_way.tags, Tag(attribute(tag, "k"), attribute(tag, "v")))
        end
        push!(way_arr, cur_way)
    end
    return way_arr
end

export open_file, parse_nodes, parse_ways, Node, Tag, Way

end
