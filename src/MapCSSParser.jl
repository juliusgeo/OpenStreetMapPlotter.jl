function parse_css(filepath::String)
	open(filepath) do file
		pos = 0
		
		while !eof(file)
				str = readuntil(file, '}')
				match_selector = match(r"([a-z]+)\s*?({|\[)", str)
				print(match_selector[1])
				for i in eachmatch(r"\[.+?\]", str)
					if i != nothing
						print(i.match)
					end	
				end
				println()
				for m in eachmatch(r"([a-z]+?):(.+?);", str)
					tag = m[1]
					val = m[2]
					println("\t"*tag*": "*val)
				end
		end
	end
end