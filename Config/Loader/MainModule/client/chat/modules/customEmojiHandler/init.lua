local players = game:GetService("Players")

local initialize = function(chatVariables)
	local getCustomEmojisFor = function(player)
		if not player then
			return chatVariables.config.CustomEmojis
		end
		return chatVariables.config.CustomEmojis
	end
	
	local lineDetector = require(script.lineDetector)(chatVariables.xml,chatVariables.chatUi,chatVariables.config,getCustomEmojisFor)
	local cache = require(script.cache)
	local utility = chatVariables.utility

	local createLayout = function()
		local layout = Instance.new("UIListLayout")
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Name = "Layout"
		layout.Wraps = true
		return layout
	end
	
	local createBox = function(label)
		local box = Instance.new("TextBox")
		box.Name = "EditBox"
		box.ClearTextOnFocus = false
		box.FontFace = label.FontFace
		box.Size = UDim2.fromOffset(0,0)
		box.TextSize = label.TextSize
		box.TextWrapped = true
		box.ZIndex = label.ZIndex + 2
		box.Text = ""
		box.BackgroundTransparency = 1
		box.Visible = false
		box.TextColor3 = label.TextColor3
		return box
	end

	chatVariables.lineDetector = lineDetector

	return {
		setText = function(self,label,text,message)
			if not label:FindFirstChild("Layout") then
				createLayout().Parent = label
				createBox(label).Parent = label.Parent
			end
			
			local editBox,layout = label.Parent:FindFirstChild("EditBox"),label:FindFirstChild("Layout")

			utility.handleChildrenOfClasses(label,{"TextLabel","ImageLabel"},function(object)
				cache:store(object)
			end)

			label.Text = ""
			label.AutomaticSize = Enum.AutomaticSize.XY

			local labels = {}

			for key,letter in pairs(lineDetector:breakdown(text,label.FontFace,message and players:GetPlayerByUserId(message.TextSource.UserId) or nil)) do	
				local created;
				if typeof(letter) == "table" then
					local imageLabel = chatVariables.customEmojiHandler:createImage(label,letter.image)
					imageLabel.LayoutOrder = key
					created = imageLabel
					if letter.color then
						imageLabel.ImageColor3 = Color3.fromHex(letter.color)
					end
				else 
					local subLetter = cache:get("TextLabel")
					subLetter.Text = letter
					subLetter.Size = UDim2.fromOffset(0,0)
					subLetter.TextSize = label.TextSize
					subLetter.AutomaticSize = Enum.AutomaticSize.XY
					subLetter.FontFace = label.FontFace
					subLetter.BackgroundTransparency = 1
					subLetter.TextColor3 = label.TextColor3
					subLetter.ZIndex = label.ZIndex + 1
					subLetter.RichText = true
					subLetter.LayoutOrder = key
					subLetter.Parent = label

					table.insert(labels,subLetter)
					created = subLetter
				end

				if key == 1 then
					local updateSize = function()
						editBox.Size = UDim2.fromOffset(
							layout.AbsoluteContentSize.X,
							layout.AbsoluteContentSize.Y
						)
					end
					
					local handler = label.Changed:Connect(function()
						editBox.FontFace = label.FontFace
						editBox.TextSize = label.TextSize
						for _,sublabel in pairs(labels) do
							if sublabel:IsA("ImageLabel") then
								sublabel.Size = UDim2.fromOffset(label.TextSize,label.TextSize)
							else
								sublabel.TextSize = label.TextSize
								sublabel.FontFace = label.FontFace
							end
						end
						updateSize()
					end)
					
					created.AncestryChanged:Once(function()
						handler:Disconnect()
						table.clear(labels)
					end)
					
					updateSize()
				end
			end
		end,
		breakdown = function(self,label,text)
			return lineDetector:breakdown(text,label.FontFace)
		end,
		getCustomEmojisFor = function(self,player)
			return getCustomEmojisFor(player)
		end,
		createImage = function(self,label,imageName)
			local imageLabel = cache:get("ImageLabel")

			imageLabel:SetAttribute("IsEmoji",true)
			imageLabel.Image = chatVariables.config.CustomEmojis[imageName]
			imageLabel.Size = UDim2.fromOffset(label.TextSize,label.TextSize)
			imageLabel.BackgroundTransparency = 1
			imageLabel.ZIndex = label.ZIndex + 1
			imageLabel.Parent = label
			
			return imageLabel
		end,
	}
end

return {initialize = initialize}