function parse_css(filepath::String)
	open(filepath) do file		
		out = []
		while !eof(file)
				ind_out = []
				selector_dict = Dict()
				str = readuntil(file, '}')
				match_selector = match(r"([a-z]+)\s*?({|\[)", str)
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
				color = 0xFFFFFF
				width = 0
				spec = "-"
				polygon = false
				for m in eachmatch(r"([a-z]+?):(.+?);", str)
					tag = m[1]
					val = m[2]
					if(tag == "color")
						color = tryparse(Int, val)
						if(color == nothing)
							color = String(val)
						end
					end
					if(tag == "width")
						width = tryparse(Int, val)
						if(width == nothing)
							width = 1
						end
					end
				end
				push!(ind_out, Style(color, width, spec, polygon))
				tupleized=tuple(ind_out...)
				push!(out, tupleized)
		end
		return out
	end
end