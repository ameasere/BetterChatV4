return function(fromXml,chatUi,config,getCustomEmojisFor)
	local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
	local textService = game:GetService("TextService")
		
	local _gsub_escape_table = {
		["\000"] = "%z", ["("] = "%(", [")"] = "%)", ["."] = "%.",
		["%"] = "%%", ["+"] = "%+", ["-"] = "%-", ["*"] = "%*",
		["?"] = "%?", ["["] = "%[", ["]"] = "%]", ["^"] = "%^",
		["$"] = "%$",
	}

	local escapePattern = function(str)
		return str:gsub("([%z%(%)%.%%%+%-%*%?%[%]%^%$])", _gsub_escape_table)
	end

	local byLetter = function(inputString,callback,spacing)
		for idx,codepoint in utf8.codes(inputString) do
			callback(utf8.char(codepoint),idx)
		end
	end

	local splitXmlAndText = function(input,override)
		local result = {}
		local stack = {}
		local lastIndex = 1

		-- Helper function to add text segments to the result
		local function addText(start, stop)
			if start <= stop then
				local text = input:sub(start, stop)
				table.insert(result, {["type"] = "text", content = text})
			end
		end

		while true do
			local tagStart, tagEnd = input:find("</?[%w:][^>]*>%s*", lastIndex)
			if not tagStart then
				addText(lastIndex, #input)
				break
			end

			local spacesStart, spacesEnd = input:find("^%s*", tagEnd + 1)
			if spacesStart then
				tagEnd = spacesEnd
			end

			if #stack == 0 then
				addText(lastIndex, tagStart - 1)
			end

			local tag = input:sub(tagStart, tagEnd)
			if tag:match("^</") then -- Closing tag
				if #stack > 0 then
					local openTagStart = table.remove(stack)
					if #stack == 0 then
						local content = input:sub(openTagStart, tagEnd)
						local toAdd;
						if(content:sub(#content,#content) == " ") then
							toAdd = tagEnd
							content = content:sub(1,#content-1)
						end
						if not override then
							table.insert(result, {["type"] = "xml", content = fromXml(content)})
						else
							table.insert(result, {["type"] = "text", content = content})
						end
						if toAdd then
							addText(tagEnd,tagEnd)
						end
					end
				end
			else
				table.insert(stack, tagStart)
			end

			lastIndex = tagEnd + 1
		end

		return result
	end

	local getIndex = function(dict)
		if(dict[1]) then
			return 1
		end
		for k,v in pairs(dict) do
			if(k ~= "_attr") then
				return k
			end
		end
	end

	local recurse;
	recurse = function(tag,index,depth,base)
		depth += 1
		local idx = getIndex(tag)
		if not base then
			base = tag
		end
		if(typeof(tag[idx]) == "table") then
			if(depth < 100) then
				local indexed = index or {}
				table.insert(indexed,idx)
				return recurse(tag[idx],indexed,depth,base)
			end
		else
			local indexed = index or {}
			table.insert(indexed,idx)
			return indexed
		end
	end

	local constructProxy = function()
		local gui = chatUi

		local label = Instance.new("TextLabel")
		label.Parent = gui
		label.TextWrapped = true
		label.AutomaticSize = Enum.AutomaticSize.Y
		label.RichText = true
		label.TextTransparency = 1
		label.BackgroundTransparency = 1
		label.Name = "WrappingLabel"
		
		return label
	end

	local proxyLabel = constructProxy()

	local wrapLabel = function(label)
		proxyLabel.Size = UDim2.fromOffset(label.AbsoluteSize.X,label.TextSize)
		proxyLabel.TextXAlignment = label.TextXAlignment
		proxyLabel.TextYAlignment = label.TextYAlignment
		proxyLabel.Text = label.Text
		proxyLabel.Font = label.Font
		proxyLabel.TextSize = label.TextSize
	end

	local lineDetector = {}
	
	function lineDetector:breakdown(text,font,player)
		for customEmoji,imageId in pairs(getCustomEmojisFor(player)) do
			text = text:gsub(escapePattern(customEmoji),`<image id="{customEmoji}">_</image>`)
		end
		
		local response;
		
		if(text:find("<")) then
			response = splitXmlAndText(text)
		else
			response = {
				{
					["type"] = "text",
					["content"] = text
				}
			}
		end

		local format = function(letter,italic,bold,color,stroke,imageId)
			if(italic == Enum.FontStyle.Italic) then
				letter = `<i>{letter}</i>`
			end
			if(bold == Enum.FontWeight.Bold) then
				letter = `<b>{letter}</b>`
			end
			if(color) then
				letter = `<font color="{color}">{letter}</font>`
			end
			if(stroke) then
				letter = `<stroke color="{stroke.color}" thickness="{stroke.thickness}" joins = "{stroke.joins}">{letter}</stroke>`
			end
			if(imageId) then
				letter = {
					color = color,
					stroke = stroke and {
						color = stroke.color,
						thickness = stroke.thickness,
						joins = stroke.joins
					} or nil,
					image = imageId
				}
			end
			return letter
		end

		local richText = {}
		local count = 0
		for key, text in pairs(response) do
			text.style = font
			text.letters = {}
			if text["type"] == "xml" then
				local innerContent = text.content
				for _,tag in pairs(recurse(text.content, nil, 0)) do
					if tag == "i" then
						text.style.Style = Enum.FontStyle.Italic
					elseif tag == "b" then
						text.style.Weight = Enum.FontWeight.Bold
					elseif tag == "font" then
						text.color = innerContent[tag]["_attr"]["color"]
					elseif tag == "stroke" then
						text.stroke = {}
						text.stroke.color = innerContent[tag]["_attr"]["color"]
						text.stroke.joins = innerContent[tag]["_attr"]["joins"]
						text.stroke.thickness = innerContent[tag]["_attr"]["thickness"]
					elseif tag == "image" then
						text.imageId = innerContent[tag]["_attr"]["id"]
					end
					innerContent = innerContent[tag]
				end
				text.content = innerContent
				local txt = ""
				local idx = 0
				byLetter(text.content,function(letter,i)
					idx += 1
					count += 1
					richText[count] = format(letter,text.style.Style,text.style.Weight,text.color,text.stroke,text.imageId)
					text.letters[idx] = letter
				end)
			else
				local idx = 0
				byLetter(text.content,function(letter,i)
					count += 1
					idx += 1
					text.letters[idx] = letter
				end)
			end
		end
		
		local c = 0
		local words = {}
		local k = 1
		
		for _,text in pairs(response) do
			for key,letter in pairs(text.letters) do
				c += 1
				if richText[c] then
					text.letters[key] = richText[c]
				end
				if typeof(text.letters[key]) == "table" then
					words[k] = text.letters[key]
					k += 1
				else
					words[k] = words[k] or ""
					words[k] = words[k] .. text.letters[key]
				end
				if letter:match("%s") then
					k += 1
				end
			end
		end
		
		return words
	end
	
	function lineDetector:splitXml(text)
		return splitXmlAndText(text,true)
	end

	local size = Instance.new("UISizeConstraint")
	size.Parent = proxyLabel

	function lineDetector:getTextSize(object,text,maxX)
		size.MaxSize = Vector2.new((maxX or math.huge),math.huge)
		wrapLabel(object)
		if maxX then
			proxyLabel.Size = UDim2.new(0,maxX,0,0)
		end
		proxyLabel.Text = text
		proxyLabel.AutomaticSize = Enum.AutomaticSize.Y
		return proxyLabel.TextBounds
	end

	return lineDetector
end