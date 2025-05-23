local localPlayer = game:GetService("Players").LocalPlayer

local list = require(script.emojiList)
local autofill = {}

autofill.beginsWith = ":"
autofill.endsWith = ":"

function autofill.onCapture(matches,chatVariables)
	local gsub,fill = {},{}
	local customEmojis = chatVariables.customEmojiHandler:getCustomEmojisFor(localPlayer)
	
	for _,match in pairs(matches) do
		if not match.hasClosing then
			for emojiName,emojiImage in pairs(customEmojis) do
				local split = emojiName:split(":")
				if #split == 3 and split[2]:sub(1,#match.text):lower() == match.text:lower() then
					table.insert(fill,{
						text = emojiName,
						autofillBar = match.before .. emojiName,
						gsub = {(":%s"):format(match.text),emojiName.." "},
						image = function(label)
							return chatVariables.customEmojiHandler:createImage(label,emojiName)
						end,
					})
				end
			end
			for _,emojiMatch in pairs(list.search(match.text)) do
				table.insert(fill,{
					text = (":%s: %s"):format(unpack(emojiMatch)),
					autofillBar = match.before .. ":" .. emojiMatch[1] .. ":",
					gsub = {(":%s"):format(match.text),emojiMatch[2].." "}
				})
			end
		else
			local replacement = list:findDirect(match.text)
			if replacement then
				gsub[(":%s:"):format(match.text)] = replacement
			end
		end
	end

	return gsub,fill
end

return autofill