#!/usr/bin/env julia
 
#Start Test Script
using OpenStreetMapParser2
import Base.Test
 
# Run tests
 
println("Test xml parsing")
#@time @test_throws parse_ways("blahblah.osm")
@time @test way_arr, bbox = parse_ways(open_file("west_philly.osm"))
@time @test way_arr.nodes == Node[Node(-75.1758, 39.956, "109728966"), Node(-75.1757, 39.9564, "3513769053"), Node(-75.1756, 39.9565, "109728979")]
@time @test way_arr.tags == Dict{Any,Any}("name"=>"Schuylkill River","waterway"=>"river")
@time savejson(way_arr, "test.geojson") 