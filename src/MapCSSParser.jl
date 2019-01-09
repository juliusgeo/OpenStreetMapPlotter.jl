function parse_css(filepath::String)
	open(filepath) do file		
		out = []
		while !eof(file)
				ind_out = []
				selector_dict = Dict()
				str = readuntil(file, '}')
				match_selector = match(r"([a-z]+)\s*?({|\[)", str)
				if match_selector == nothing
					continue
				end
				show(match_selector)
				selector = match_selector[1]
				push!(ind_out,selector)
				for i in eachmatch(r"((?<=\[).+?(?=\]))", str)
					if i != nothing
						if occursin(r"(.+?)([!|=|<|>|~]{1,2})(.+)", i.match)
							m = match(r"(.+?)([!|=|<|>|~]{1,2})(.+)", i.match)
							operator = m[2]
							selector_dict[m[1]] = (m[3], operator)
						else
							selector_dict[i.match] = ("yes", "=")
						end
					end
				end
				push!(ind_out,selector_dict)
				cur_style = Dict("color"=>0xD3D3D3, "width"=>0, "spec"=>"-", "is_polygon"=>false, "font-size"=>.6)
				for m in eachmatch(r"([a-z]+?):(.+?);", str)
					tag = m[1]
					val = m[2]
					if(tag == "color")
						cur_style["color"] = tryparse(Int, val)
						if(cur_style["color"]  == nothing)
							cur_style["color"]  = String(val)
						end
					end
					if(tag == "width")
						cur_style["width"] = tryparse(Int, val)
						if(cur_style["width"] == nothing)
							cur_style["width"] = 1
						end
					end
					if(tag == "font-size")
						cur_style["font-size"] = tryparse(Float64, val)
					end
					if(tag == "text")
						cur_style["text"] = val
					end
				end
				push!(ind_out, cur_style)
				tupleized=tuple(ind_out...)
				push!(out, tupleized)
		end
				println()
		println()
		println()

		for i in out
			println("Rule:")
			println(i)
		end
				println()
		println()
		println()

		return out
	end
end