struct Node
    x::Float64
    y::Float64
    id::String
end

mutable struct Style
	color::UInt
	width::Int
	spec::String
    polygon::Bool
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