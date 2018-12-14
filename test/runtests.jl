#!/usr/bin/env julia
 
#Start Test Script
using OpenStreetMapPlotter
import Test
using Pkg
# Run tests

println("Testing xml parsing...")
way_arr, bbox = parse_ways(open_file("west_philly.osm"))
test_nodes = way_arr[1].nodes[1:10]
Test.@test test_nodes[1].id == "27149008"
Test.@test test_nodes[2].id == "588195318"
Test.@test test_nodes[3].id == "27149007"
Test.@test test_nodes[4].id == "27149006"
Test.@test test_nodes[5].id == "27149005"
Test.@test test_nodes[6].id == "1288458928"
Test.@test test_nodes[7].id == "27149004"
Test.@test test_nodes[8].id == "27149003"
Test.@test test_nodes[9].id == "1288458923"
Test.@test test_nodes[10].id == "27149002"
Test.@test way_arr[1].tags == Dict{Any,Any}("name"=>"Schuylkill River","waterway"=>"river")
Test.@time save_json(way_arr, "test.geojson") 
plot_ways(way_arr, bbox)