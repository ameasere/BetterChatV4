local userInputService = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")

local initialize = function(chatVariables)
	local chatbar = chatVariables.uiObjects.chatbar
	local utility = chatVariables.utility
	local channelBar = chatVariables.uiObjects.channelBar
	local window = chatVariables.uiObjects.window
	local additionalContext = chatVariables.uiObjects.additionalContext

	local box = chatbar.Chatbox
	local padding = chatVariables.uiPadding
	local scroller = chatVariables.uiObjects.messageScroller
	local autofillBar = chatbar.AutofillBar
	local actionIcon = chatbar.ActionIcon
	
	local updateSizes = function()
		local textBounds = utility.getTextBoundsFromObject(box,chatbar.AbsoluteSize.X - padding * 2)
		chatbar.Size = UDim2.new(
			1,0,
			0,(math.ceil(textBounds.Y) + padding * 3)
		)

		local cbs = channelBar.Visible and channelBar.AbsoluteSize.Y or 0
		
		local lastSize = scroller.Size
		
		scroller.Size = UDim2.new(
			1,0,
			0,window.AbsoluteSize.Y - chatbar.AbsoluteSize.Y - cbs - padding * (cbs > 0 and 4 or 3)
		)
		
		local sizeDifference = (scroller.Size - lastSize).Y.Offset
		scroller.CanvasPosition -= Vector2.new(0,sizeDifference)

		chatbar.Position = UDim2.fromOffset(0,
			scroller.AbsoluteSize.Y + cbs + padding * (cbs > 0 and 2 or 1) - 30 -- 30px offset for the new Additional Context feature
		)

		scroller.Position = UDim2.fromOffset(0,(cbs > 0 and (cbs + padding) or 0))
	end

	utility.onPropertyChanged(box,"Text",updateSizes)
	utility.updateSizes = updateSizes

	local keycode = chatVariables.configurations.chatbarConfiguration.KeyboardKeyCode

	userInputService.InputBegan:Connect(function(input,gameProcessed)
		if(not gameProcessed and input.KeyCode == keycode) then
			if chatVariables:getChatOpenState() then
				task.wait()
				box:CaptureFocus()
			end
		end
	end)
	
	chatVariables.sendMessage = function(box,context)
		local escaped = chatVariables.richText:escape(box.Text)
		local parsed = chatVariables.richText:markdown(escaped,true)
		local stripped_escaped = chatVariables.richText:strip(parsed)
		local stripped = chatVariables.richText:unescape(stripped_escaped)

		chatVariables.connections:Fire("ChatWindow","MessagePosted",stripped)

		local message = chatVariables.currentChannel:SendAsync(stripped,httpService:JSONEncode({
			["original"] = box.Text,
			["context"] = context
		}))
		
		additionalContext.ContextLabel.Text = ""
	end

	box.FocusLost:Connect(function(enterPressed)
		chatVariables.network:fire("typingIndicator",false)
		if enterPressed and chatVariables:getChatOpenState() and #box.Text > 0 then
			if(#box.Text:gsub(string.char(32),"") ~= 0) then
				chatVariables.sendMessage(box,chatVariables.messageContext or {})
			end
			box.Text = ""
		end
	end)
	
	local lastText,expiresAt = "",0

	local timeout = function()
		task.spawn(function()
			local current = expiresAt
			task.wait((expiresAt-tick()))
			if(current == expiresAt) then
				chatVariables.network:fire("typingIndicator",false)
			end
		end)
	end

	local logChange = function()
		if(box:IsFocused()) then
			chatVariables.network:fire("typingIndicator",true)
			expiresAt = tick() + 5
			timeout()
		else
			chatVariables.network:fire("typingIndicator",false)
		end
	end
	
	local lastText = ""
	box:GetPropertyChangedSignal("Text"):Connect(function()
		logChange()
		if(#box.Text > 185) then
			box.Text = lastText
		else
			lastText = box.Text
		end
	end)
	
	box.Focused:Connect(logChange)
	
	box.PlaceholderText = chatVariables.localization:getChatbarPlaceholder()
	
	local component = {}
	
	function component:assignActionImage(imageId,context)
		chatVariables.messageContext = context
		box.Size = UDim2.new(1,-(box.TextSize * 2),1,0)
		autofillBar.Size = UDim2.new(1,-(box.TextSize * 2),1,0)
		actionIcon.Visible = true
		actionIcon.Img.Image = imageId
	end
	
	function component:unassign()
		chatVariables.messageContext = nil
		chatVariables.uiObjects.additionalContext.ContextLabel.Text = ""
		box.Size = UDim2.new(1,0,1,0)
		autofillBar.Size = UDim2.new(1,0,1,0)
		actionIcon.Visible = false
	end
	
	actionIcon.MouseButton1Click:Connect(component.unassign)
	
	return component
end

return {initialize = initialize}