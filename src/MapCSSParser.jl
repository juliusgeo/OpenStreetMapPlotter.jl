function parse_css(filepath::String)
	open(filepath) do file
		while !eof(file)
				str = readuntil(file, '{')
				match_selector = match(r"([a-z]+)(\[.+?\])*", str)
				show(match_selector)
				println()
				str = readuntil(file, ';')
				while(occursin(r"([a-z]+?):(.+)", str))
					match_properties = match(r"([a-z]+?):(.+)", str)
					show(match_properties)
					println()
					str = readuntil(file, ';')
				end	
		end
	end
end