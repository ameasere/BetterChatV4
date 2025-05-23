local httpService = game:GetService("HttpService")
local userInputService = game:GetService("UserInputService")
local separateTime = 50
local maxBubbles = 100

local holdDurations = {
	["Computer"] = 0.6,
	["Phone"] = 0.45
}

local initialize = function(chatVariables)
	local lineDetector = chatVariables.lineDetector

	local bases = {}
	local container = {}
	local bubbles = {}
	local mouseState = {}

	local utility = chatVariables.utility
	local scroller = chatVariables.uiObjects.messageScroller
	local designFolder = chatVariables.designs

	local uiPadding = chatVariables.uiPadding

	local getScrollerSize = function()
		return scroller.AbsoluteSize
	end
	
	local colorize = function(name,messageData,suffix)
		return chatVariables.richText:colorize(name .. (suffix or ""),messageData.nameColor or utility:getNameColor(
			name
		))
	end

	local designs = {
		Message = designFolder.Message,

		TopBubble = designFolder.bubbles.chain.TopBubble,
		BottomBubble = designFolder.bubbles.chain.BottomBubble,

		DefaultBubble = designFolder.bubbles.DefaultBubbleHolder,
		ReplyStartBubble = designFolder.bubbles.ReplyStartBubble,
		ReplyingToPreviousBubbleChain = designFolder.bubbles.ReplyingToPreviousBubbleChain
	}

	local create = function(name,parent)
		local clone = designs[name]:Clone()
		if parent then
			clone.Parent = parent
		end
		return clone
	end

	local handle = function(text,messageData)
		return chatVariables.richText:markdown(text,true)
	end

	local textHandler = chatVariables.customEmojiHandler

	local handleOverflows = function()
		if #bubbles + 1 > maxBubbles then
			bases[1]["controllers"][1]:delete()
		end
	end

	local newModifier = function(info,data)
		local label,connections = unpack(info)

		local bubble = label.Parent.Parent
		local connectedToBase = container[bubble]

		handleOverflows()

		local controller;
		controller = {
			connectedTo = nil,
			object = bubble,
			setText = function(self,text)
				textHandler:setText(label,handle(text,data),data.object)
			end,
			delete = function()
				local base = controller.connectedTo
				local removeFrom = base.controllers
				local idx = table.find(removeFrom,controller)
				table.remove(removeFrom,idx)

				if #removeFrom == 0 then
					local idx = table.find(bases,base)
					table.remove(bases,idx)
					base:delete()
				end

				for k,b in pairs(bubbles) do
					if b.bubble == bubble then
						table.remove(bubbles,k)
					end
				end

				bubble:Destroy()
				for _,connection in pairs(connections) do
					connection:Disconnect()
				end
			end,
			data = data,
			addReaction = function(self,player,reaction)
				if not bubble:FindFirstChild("ReactionContainer") then
					local frame = Instance.new("Frame")
					frame.Parent = bubble
					frame.Name = "ReactionContainer"
					frame.Size = UDim2.new(0,0,0,0)
					frame.BorderSizePixel = 0
					frame.AutomaticSize = Enum.AutomaticSize.XY
					frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
					frame.BackgroundTransparency = 0.5

					local roundness = Instance.new("UICorner")
					roundness.Parent = frame
					roundness.CornerRadius = UDim.new(1,0)

					local padding = Instance.new("UIPadding")
					padding.PaddingTop = UDim.new(0,uiPadding)
					padding.PaddingBottom = UDim.new(0,uiPadding)
					padding.PaddingLeft = UDim.new(0,uiPadding)
					padding.PaddingRight = UDim.new(0,uiPadding)
					padding.Parent = frame

					local layout = Instance.new("UIListLayout")
					layout.Parent = frame
					layout.FillDirection = Enum.FillDirection.Horizontal
					layout.Padding = UDim.new(0,uiPadding)

					local actualBubble = bubble.DefaultBubble

					local movePosition = function()
						frame.Position = UDim2.fromOffset(
							0,
							actualBubble.AbsoluteSize.Y + 2
						)
					end

					table.insert(connections,actualBubble.Changed:Connect(movePosition))
					movePosition()
				end

				local reactionContainer = bubble.ReactionContainer

				local emoji = Instance.new("TextButton")
				emoji.Text = reaction
				emoji.TextSize = label.TextSize
				emoji.Size = UDim2.fromOffset(emoji.TextSize,emoji.TextSize)
				emoji.Parent = reactionContainer
				emoji.BackgroundTransparency = 1

				local padding = Instance.new("UIPadding")
				padding.PaddingTop = UDim.new(0,uiPadding)
				padding.PaddingBottom = UDim.new(0,uiPadding)
				padding.PaddingLeft = UDim.new(0,uiPadding)
				padding.PaddingRight = UDim.new(0,uiPadding)
				padding.Parent = emoji

				table.insert(connections,label:GetPropertyChangedSignal("TextSize"):Connect(function()
					emoji.TextSize = label.TextSize
					emoji.Size = UDim2.fromOffset(emoji.TextSize,emoji.TextSize)
				end))
			end,
		}

		for _,baseInfo in pairs(bases) do
			if baseInfo.object == connectedToBase then
				table.insert(baseInfo.controllers,controller)
				controller.connectedTo = baseInfo
			end
		end

		table.insert(bubbles,{
			controller = controller,
			base = connectedToBase,
			bubble = bubble
		})

		return controller
	end

	local messagesByIds = {}
	local messageObjectById = {}

	local guidToId = function(guid)
		for id,data in pairs(messagesByIds) do
			if data.guid == guid then
				return id
			end
		end
	end

	local scaleBubble = function(bubble,label,messageBase,constraint,messageData)
		local icon = messageBase.Actual.Icon

		local autoscale = function()
			local textBounds = lineDetector:getTextSize(label,label.Text,(constraint.MaxSize.X - uiPadding * 3))
			label.Size = UDim2.fromOffset(math.ceil(textBounds.X),math.ceil(textBounds.Y))
			icon.Size = UDim2.fromOffset(
				label.TextSize + 10,
				label.TextSize + 10
			)

			if not messageData.disableBubbling then
				messageBase.Username.TextSize = label.TextSize - 1
				messageBase.Username.UIPadding.PaddingLeft = UDim.new(
					0,
					icon.Visible and label.TextSize + 10 + uiPadding or 0
				)
			end
		end

		local inside = function(state)
			mouseState[label] = {
				since = tick(),
				inBounds = state,
				messageData = messageData
			}
		end

		local textChanged = utility.onPropertyChanged(label,"Text",autoscale)
		local textSizeConnection = utility.onPropertyChanged(label,"TextSize",autoscale)
		local iconVisible = utility.onPropertyChanged(icon,"Visible",autoscale)
		local inBounds,internal = utility.mouse:detectInObject(bubble):Connect(inside)

		return {
			textSizeConnection,
			iconVisible,
			textChanged,
			inBounds,
			internal
		}
	end

	local createMessage = function(messageData,iconEnabled)
		if messageData.npc or not messageData.senderId then
			messageData.id = chatVariables:newMessageId()
			messageData.guid = httpService:GenerateGUID()
		end

		messagesByIds[messageData.id] = messageData

		local createBubble;

		local instantiate = function()
			local messageBase = create("Message")
			messageObjectById[messageData.id] = messageBase

			messageBase.Actual.Icon.Visible = iconEnabled
			messageBase.Username.Text = messageData.displayName or messageData.username

			table.insert(bases,{
				object = messageBase,
				controllers = {},
				delete = function(self)
					self.object:Destroy()
				end,
			})

			if iconEnabled then
				if(not messageData.icon and (not messageData.npc)) then
					messageData.icon = utility.getThumbnailFromId(messageData.senderId)
				end
				if typeof(messageData.icon) == "table" then
					for property,value in pairs(messageData.icon) do
						messageBase.Actual.Icon[property] = value
					end
				else
					messageBase.Actual.Icon.Image = messageData.icon
				end
			end

			local bubbleHolder = messageBase.Actual.BubbleHolder

			local maxSizeConstraint = bubbleHolder:WaitForChild("SizeConstraint")

			local connections = {}

			local requestIconInformation = function()		
				return messageBase.Actual.Icon.Visible,messageBase.Actual.Icon.AbsoluteSize.X
			end

			local adjust = function()
				local absoluteSize = getScrollerSize()
				local iconEnabled,iconSize = requestIconInformation()

				local maximumSize = absoluteSize.X - (iconEnabled and (iconSize + uiPadding) or 0)
				maxSizeConstraint.MaxSize = Vector2.new(maximumSize,math.huge)
				if not messageData.disableBubbling then
					messageBase.Username.UIPadding.PaddingLeft = UDim.new(0,iconEnabled and (iconSize + uiPadding) or 0)
				end
			end

			local store = function(...)
				for _,connection in pairs({...}) do
					table.insert(connections,connection)
				end
				task.spawn(adjust)
			end

			createBubble = function(bubbleClass,messageData,presentData)
				local toReturn;
				if bubbleClass == "ReplyingToPreviousBubbleChain" then
					local replyingTo = messagesByIds[messageData.replyingTo]				
					-- could use replyingTo.selfReplies = replyingTo.selfReplies or {}
					-- however, this would break if the user deletes a message from the chain
					-- and cause duplication (in theory)

					if(not replyingTo.selfReplies) then 
						replyingTo.selfReplies = {}
						replyingTo.bubbleHolder = create("ReplyingToPreviousBubbleChain",bubbleHolder)
					end

					table.insert(replyingTo.selfReplies,messageData)
					utility.clearChildrenOfClass(replyingTo.bubbleHolder,"Frame")

					local last;
					if #replyingTo.selfReplies == 1 then
						local bubble = create("BottomBubble",replyingTo.bubbleHolder)
						last = bubble.Bubble.Label
						textHandler:setText(bubble.Bubble.Label,handle(messageData.text,messageData),messageData.object)
					else
						for key,reply in pairs(replyingTo.selfReplies) do
							local bubble = create(
								(key < #replyingTo.selfReplies and "TopBubble" or "BottomBubble"),
								replyingTo.bubbleHolder
							)
							textHandler:setText(bubble.Bubble.Label,handle(reply.text,reply),reply.object)
							last = bubble.Bubble.Label
						end
					end

					toReturn = {
						last,{}
					}
				else
					local bubble = create(bubbleClass)
					container[bubble] = messageBase

					if bubbleClass == "DefaultBubble" then
						if messageData.disableBubbling then
							bubble.DefaultBubble.BackgroundTransparency = 1
							bubble.DefaultBubble.Tail.BackgroundTransparency = 1
							if messageBase:FindFirstChild("Username") then
								local userText = messageBase.Username.Text
								messageData.text = `{colorize(userText,messageData,":")} {messageData.text}`
								messageBase.Username:Destroy()
								bubble.DefaultBubble:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0,0)
							end
						end
						local label = bubble.DefaultBubble.Label
						textHandler:setText(label,handle(messageData.text,messageData),messageData.object)

						local connections = scaleBubble(bubble,label,messageBase,maxSizeConstraint,messageData)						
						toReturn = {label,connections}
					elseif bubbleClass == "ReplyStartBubble" then						
						messageBase.Username.Text = chatVariables.localization:localize("ReplyingTo",nil,{
							["SPEAKER_1"] = presentData.displayName,
							["SPEAKER_2"] = messageData.displayName
						})
						textHandler:setText(bubble.OriginalBubble.Label,handle(messageData.text,messageData),messageData.object)
						toReturn = bubble.OriginalBubble
					end

					bubble.LayoutOrder = messageData.id
					bubble.Parent = bubbleHolder
					local listToSort = {}

					-- tail:

					for _,potentialBubble in pairs(bubbleHolder:GetChildren()) do
						if(potentialBubble:IsA("Frame") and potentialBubble.Name == "DefaultBubble") then
							table.insert(listToSort,{
								id = potentialBubble.LayoutOrder,
								object = potentialBubble
							})
						end
					end
					table.sort(listToSort,function(a,b)
						return(a.id < b.id)
					end)
					for key,sortedBubble in pairs(listToSort) do
						sortedBubble.object.DefaultBubble.Tail.Visible = key < 2
					end
				end
				return toReturn
			end

			store(
				scroller:GetPropertyChangedSignal("Size"):Connect(adjust),
				messageBase.Actual.Icon:GetPropertyChangedSignal("Visible"):Connect(adjust)
			)

			messageData.access = {createBubble = function(self,...)
				return createBubble(...)
			end}

			messageBase.Parent = scroller
		end

		if messageData.npc then						
			instantiate()
			return newModifier(createBubble("DefaultBubble",messageData),messageData)
		else
			if messageData.replyingTo ~= nil and messagesByIds[messageData.replyingTo] then
				local previousData = messagesByIds[messageData.replyingTo]
				if previousData.senderId == messageData.senderId then
					local difference = messageData.id - previousData.id
					if difference == 1 then
						return newModifier(previousData.access:createBubble("ReplyingToPreviousBubbleChain",messageData),messageData)
					else
						instantiate()
						createBubble("ReplyStartBubble",previousData,messageData)
						return newModifier(createBubble("DefaultBubble",messageData),messageData)
					end
				else
					local previousMessage = messagesByIds[messageData.id - 1]
					if (previousMessage and previousMessage.senderId == messageData.senderId) and (previousMessage.replyingTo == messageData.replyingTo) then
						for _,message in pairs(messagesByIds) do
							if(message.id > messageData.replyingTo) then
								if (previousMessage and previousMessage.senderId == messageData.senderId) and (previousMessage.replyingTo == messageData.replyingTo) then
									return newModifier(message.access:createBubble("DefaultBubble",messageData),messageData)
								end
							end
						end
					else
						instantiate()
						createBubble("ReplyStartBubble",previousData,messageData)
						return newModifier(createBubble("DefaultBubble",messageData),messageData)
					end
				end
			else
				local previous = messagesByIds[messageData.id - 1] or {}
				if messageData.senderId == previous.senderId and (messageData.sentAt - previous.sentAt <= separateTime) and (not previous.replyingTo) then
					local previous2 = messagesByIds[messageData.id - 2]
					local i,origin = 0,nil
					if previous2 then
						repeat
							i += 1
							local previous = messagesByIds[messageData.id - i] or {}
							if(not previous) then
								break
							elseif messageData.senderId == previous.senderId and (messageData.sentAt - previous.sentAt <= separateTime) then
								if previous.replyingTo ~= nil then
									break
								else
									origin = previous
								end
							elseif messageData.senderId ~= previous.senderId or (messageData.sentAt - previous.sentAt >= separateTime) then
								break;
							end
						until(i > 1000)
					else
						origin = previous
					end
					return newModifier(origin.access:createBubble("DefaultBubble",messageData),messageData)
				else
					instantiate()
					return newModifier(createBubble("DefaultBubble",messageData),messageData)
				end
			end
		end
	end

	-- Context menu:

	local contextMenu = chatVariables.uiObjects.contextMenu
	local inContextMenu = false
	local currentContext;

	local respondToContextMenuAction = function(action,...)
		if currentContext then
			if action == "Reply" then
				chatVariables.components.chatbar:assignActionImage("rbxassetid://6035067844",{
					replyingTo = currentContext.data.guid
				})
			elseif action == "Edit" then
				local label = currentContext.label
				label.Visible = false

				local editBox = label.Parent.EditBox
				editBox.Visible = true
				editBox.AutomaticSize = Enum.AutomaticSize.XY
				editBox:CaptureFocus()

				editBox.BackgroundTransparency = 0.5
				editBox.BackgroundColor3 = Color3.fromRGB(20,20,20)

				local signal;
				signal = editBox.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						label.Visible = true
						editBox.Visible = false
						signal:Disconnect()
						chatVariables.sendMessage(editBox,{
							editingMessage = currentContext.data.guid
						})
					end
				end)
			elseif action == "Delete" then
			elseif action == "React" then
				chatVariables.network:fire("reactToMessage",currentContext.data.guid,({...})[1])
			end
		end
	end

	local handleContextMenu = function(label)
		local info = mouseState[label]["messageData"]
		local mousePosition = utility.mouse:getPosition()

		contextMenu.Visible = true
		contextMenu.Position = UDim2.fromOffset(mousePosition.X,mousePosition.Y)
		currentContext = {
			data = info,
			label = label
		}
	end

	utility.mouse:detectInObject(contextMenu):Connect(function(inside)
		inContextMenu = inside
	end)

	local process = function(input,duration)
		if input.UserInputState ~= Enum.UserInputState.End then
			local signal,holding = nil,true
			signal = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					holding = false
					signal:Disconnect()
				end
			end)
			local toCheck,since;
			for label,info in pairs(mouseState) do
				if info.inBounds then
					toCheck = label
					since = info.since
					break;
				end
			end
			if toCheck then
				task.delay(duration,function()
					if holding then
						if mouseState[toCheck].inBounds and mouseState[toCheck].since == since then
							handleContextMenu(toCheck)
						end
					end
				end)
			end
		end
	end

	userInputService.InputBegan:Connect(function(input)
		if contextMenu.Visible and not inContextMenu then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				contextMenu.Visible = false
			end
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			task.wait()
			process(input,holdDurations.Computer)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			task.wait()
			process(input,holdDurations.Phone)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			local toCheck;
			for label,info in pairs(mouseState) do
				if info.inBounds then
					toCheck = label
					break;
				end
			end
			if toCheck then
				handleContextMenu(toCheck)
			end
		end
	end)

	utility.handleChildrenOfClass(contextMenu,"TextButton",function(textButton)
		textButton.MouseButton1Click:Connect(function()
			contextMenu.Visible = false
			respondToContextMenuAction(textButton.Name)
		end)
	end)

	utility.handleChildrenOfClass(contextMenu.Reactions.Options,"TextButton",function(reactionButton)
		reactionButton.MouseButton1Click:Connect(function()
			contextMenu.Visible = false
			respondToContextMenuAction("React",reactionButton.Text)
		end)
	end)

	-- api:

	return {
		new = createMessage,
		guidToId = function(self,...)
			return guidToId(...)
		end,
	}
end

return {initialize = initialize}