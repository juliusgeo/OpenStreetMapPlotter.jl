highway_styles = Dict(
	"motorway" => Style(0xf98d72, 6, "-", false), #bright blue
	"trunk" => Style(0x965748, 5, "-", false), #brown
	"primary" => Style(0xff6868, 5, "-", false), #orange
	"secondary" => Style(0xfc4b4b, 4, "-", false), #orange-ish red
	"tertiary" => Style(0xfc3232, 3, "-", false), #red
	"unclassified" => Style(0xF1EEE8, 2, "-", false),
	"residential" => Style(0xF1EEE8, 2, "-", false),
	"service" => Style(0xfceec7, 1, "-", false),
	"motorway_link" => Style(0xe891a1, 2, "-", false),
	"trunk_link" => Style(0xA9A9A9, 2, "-", false),
	"primary_link" => Style(0xA9A9A9, 2, "-", false),
	"secondary_link" => Style(0xA9A9A9, 2, "-", false),
	"tertiary_link" => Style(0xA9A9A9, 2, "-", false),
	"living_street" => Style(0xF1EEE8, 2, "-", false),
	"pedestrian" => Style(0x888888, 2, "-", false),
	"pedestrian_area" => Style(0x888888, 2, "-", true),
	"track" => Style(0x909090, 1, ":", false),
	"bus_guideway" => Style(0x989898, 1, ":", false),
	"escape" => Style(0xA0A0A0, 1, ":", false),
	"raceway" => Style(0xA8A8A8, 1, ":", false),
	"road" => Style(0xA9A9A9, 1, ":", false),
	"footway" => Style(0xB0B0B0, 1, ":", false),
	"bridleway" => Style(0xB8B8B8, 1, ":", false),
	"steps" => Style(0xBEBEBE, 1, ":", false), 
	"path" => Style(0xC0C0C0, 1, ":", false) 
)
building_styles = Dict(
	"yes" => Style(0xe891a1, 1, "-", true),
	"house" => Style(0x91f2ce, 1, "-", true),
	"residential" => Style(0x91f2ce, 1, "-", true),
	"garage" => Style(0x91f2ce, 1, "-", true),
	"apartments" => Style(0x91f2ce, 1, "-", true), #all residential stuff is greenish
	"hut" => Style(0xe891a1, 1, "-", true),
	"detached" => Style(0xe891a1, 1, "-", true),
	"shed" => Style(0x876d6c, 1, "-", true),
	"terrace" => Style(0xe891a1, 1, "-", true),
	"garages" => Style(0xe891a1, 1, "-", true),
	"school" => Style(0xb2effc, 1, "-", true),
	"university" => Style(0xb2effc, 1, "-", true), #schools are blue
	"construction" => Style(0xf2d2d8, 1, "-", true),
	"farm" => Style(0xf2d2d8, 1, "-", true),
	"hotel" => Style(0xf2d2d8, 1, "-", true),
	"dormitory" => Style(0xb2effc, 1, "-", true),
	"houseboat" => Style(0xf2d2d8, 1, "-", true),
	"bungalow" => Style(0xf2d2d8, 1, "-", true),
	"static_caravan" => Style(0xf2d2d8, 1, "-", true),
	"cabin" => Style(0xf2d2d8, 1, "-", true),
	"commercial" => Style(0xfcf2b2, 1, "-", true),
	"office" => Style(0xfcf2b2, 1, "-", true),
	"industrial" => Style(0x876d6c, 1, "-", true),
	"retail" => Style(0xfcf2b2, 1, "-", true),
	"supermarket" => Style(0xf2d2d8, 1, "-", true),
	"warehouse" => Style(0xf2d2d8, 1, "-", true),
	"kiosk" => Style(0xf2d2d8, 1, "-", true),
	"religious" => Style(0xf2d2d8, 1, "-", true),
	"cathedral" => Style(0xf2d2d8, 1, "-", true),
	"chapel" => Style(0xf2d2d8, 1, "-", true),
	"church" => Style(0xf2d2d8, 1, "-", true),
	"mosque" => Style(0xf2d2d8, 1, "-", true),
	"temple" => Style(0xf2d2d8, 1, "-", true),
	"synagogue" => Style(0xf2d2d8, 1, "-", true),
	"shrine" => Style(0xf2d2d8, 1, "-", true),
	"bakehouse" => Style(0xf2d2d8, 1, "-", true),
	"kindergarten" => Style(0xb2effc, 1, "-", true),
	"civic" => Style(0xf2d2d8, 1, "-", true),
	"government" => Style(0xf2d2d8, 1, "-", true),
	"hospital" => Style(0xA9A9A9, 1, "-", true),
	"stadium" => Style(0xf2d2d8, 1, "-", true),
	"train_station" => Style(0xf2d2d8, 1, "-", true),
	"transportation" => Style(0xf2d2d8, 1, "-", true),
	"university" => Style(0xf2d2d8, 1, "-", true),
	"grandstand" => Style(0xf2d2d8, 1, "-", true),
	"public" => Style(0xf2d2d8, 1, "-", true),
	"toilets" => Style(0xf2d2d8, 1, "-", true),
	"barn" => Style(0xf2d2d8, 1, "-", true),
	"bridge" => Style(0xf2d2d8, 1, "-", true),
	"bunker" => Style(0xf2d2d8, 1, "-", true),
	"carport" => Style(0xf2d2d8, 1, "-", true),
	"conservatory" => Style(0xf2d2d8, 1, "-", true),
	"cowshed" => Style(0xf2d2d8, 1, "-", true),
	"digester" => Style(0xf2d2d8, 1, "-", true),
	"farm_auxiliary" => Style(0xf2d2d8, 1, "-", true),
	"garbage_shed" => Style(0xf2d2d8, 1, "-", true),
	"greenhouse" => Style(0xf2d2d8, 1, "-", true),
	"hangar" => Style(0xf2d2d8, 1, "-", true),
	"hut" => Style(0xf2d2d8, 1, "-", true),
	"pavilion" => Style(0xf2d2d8, 1, "-", true),
	"parking" => Style(0xf2d2d8, 1, "-", true),
	"riding_hall" => Style(0xf2d2d8, 1, "-", true),
	"roof" => Style(0xf2d2d8, 1, "-", true),
	"sports_hall" => Style(0xf2d2d8, 1, "-", true),
	"stable" => Style(0xf2d2d8, 1, "-", true),
	"sty" => Style(0xf2d2d8, 1, "-", true),
	"transformer_tower" => Style(0xf2d2d8, 1, "-", true),
	"service" => Style(0xf2d2d8, 1, "-", true),
	"ruins" => Style(0xf2d2d8, 1, "-", true),
	"water_tower" => Style(0xf2d2d8, 1, "-", true),
)
waterway_styles = Dict(
	"stream" => Style(0x9ec3ff, 3, "-", false),
	"ditch" => Style(0x9ec3ff, 1, "-", false),
	"river" => Style(0x9ec3ff, 5, "-", false),
	"drain" => Style(0x9ec3ff, 1, "-", false),
	"riverbank" => Style(0x9ec3ff, 1, "-", true),
	"canal" => Style(0x9ec3ff, 1, "-", false),
	"other" => Style(0x9ec3ff, 1, "-", false),
	"dock" => Style(0x808080, 1, "-", true),
	"boatyard" => Style(0x808080, 1, "-", true),
	"dam" => Style(0x808080, 1, "-", true),
)
leisure_styles = Dict(
	"pitch" => Style(0xbff9b6, 2, "-", true),
	"swimming_pool" => Style(0x9ec3ff, 2, "-", true),
	"park" => Style(0xbff9b6, 2, "-", true),
	"playground" => Style(0xbff9b6, 1, "-", true),
	"garden" => Style(0xbff9b6, 1, "-", true),
	"sports_centre" => Style(0x30bc0d, 1, "-", true),
	"other" => Style(0x808080, 1, "-", true),
)
nature_styles = Dict(
	"wood" => Style(0xADD19E, 2, "-", true),
	"tree_row" => Style(0xADD19E, 2, "-", false),
	"tree" => Style(0xADD19E, 2, "-", false),
	"scrub" => Style(0xB5E3B5, 2, "-", true),
	"heath" => Style(0xD6D99F, 2, "-", true),
	"grassland" => Style(0xC6E4B4, 2, "-", true),
	"bare_rock" => Style(0xDAD5D0, 2, "-", true),
	"scree" => Style(0xEDE4DC, 2, "-", true),
	"shingle" => Style(0xF9F9F9, 2, "-", true),
	"sand" => Style(0xF1E5C2, 2, "-", true),
	"mud" => Style(0xDDCEC0, 2, "-", true),
	"water" => Style(0xF9F9F9, 2, "-", true),
	"wetland" => Style(0xF9F9F9, 2, "-", true),
	"glacier" => Style(0xDDECEC, 2, "-", true),
	"bay" => Style(0xF9F9F9, 2, "-", true),
	"beach" => Style(0xFFF1BA, 2, "-", true),

)
amenity_styles = Dict(

)
tag2style = Dict(
	"waterway" => waterway_styles,
	"building" => building_styles,
	"highway" => highway_styles,
	"leisure" => leisure_styles,
	"nature" => nature_styles,
	"amenity" => amenity_styles,
)

function get_way_style(tags::Dict)
	for tag in ["waterway", "building", "amenity", "highway", "leisure", "nature"]
		if haskey(tags, tag)
			if haskey(tag2style[tag], tags[tag])
				return tag2style[tag][tags[tag]]
			end
		end
	end
	return Style(0x808080, 1, "-", false)
end