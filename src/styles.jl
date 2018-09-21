highway_styles = Dict(
	"motorway" => Style(0xf98d72, 6, "-"), #bright blue
	"trunk" => Style(0x965748, 5, "-"), #brown
	"primary" => Style(0xff6868, 5, "-"), #orange
	"secondary" => Style(0xfc4b4b, 4, "-"), #orange-ish red
	"tertiary" => Style(0xfc3232, 3, "-"), #red
	"unclassified" => Style(0xF1EEE8, 2, "-"),
	"residential" => Style(0xF1EEE8, 2, "-"),
	"service" => Style(0xfceec7, 1, "-"),
	"motorway_link" => Style(0xe891a1, 2, "-"),
	"trunk_link" => Style(0xA9A9A9, 2, "-"),
	"primary_link" => Style(0xA9A9A9, 2, "-"),
	"secondary_link" => Style(0xA9A9A9, 2, "-"),
	"tertiary_link" => Style(0xA9A9A9, 2, "-"),
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
	"commercial" => Style(0xfcf2b2, 1, "-"),
	"terrace" => Style(0xe891a1, 1, "-"),
	"garages" => Style(0xe891a1, 1, "-"),
	"school" => Style(0xb2effc, 1, "-"), #schools are blue
	"construction" => Style(0xf2d2d8, 1, "-"),
)
waterway_styles = Dict(
	"stream" => Style(0x9ec3ff, 3, "-"),
	"ditch" => Style(0x9ec3ff, 1, "-"),
	"river" => Style(0x9ec3ff, 5, "-"),
	"drain" => Style(0x9ec3ff, 1, "-"),
	"riverbank" => Style(0x9ec3ff, 1, "-"),
	"canal" => Style(0x9ec3ff, 1, "-"),
	"other" => Style(0x9ec3ff, 1, "-"),
)
leisure_styles = Dict(
	"pitch" => Style(0xbff9b6, 2, "-"),
	"swimming_pool" => Style(0x9ec3ff, 2, "-"),
	"park" => Style(0xbff9b6, 2, "-"),
	"playground" => Style(0xbff9b6, 1, "-"),
	"garden" => Style(0xbff9b6, 1, "-"),
	"sports_centre" => Style(0x30bc0d, 1, "-"),
	"other" => Style(0x808080, 1, "-"),
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