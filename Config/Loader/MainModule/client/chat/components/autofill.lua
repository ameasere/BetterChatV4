local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local heartbeat = runService.Heartbeat

local initialize = function(chatVariables)
	local extensions = chatVariables.extensions
	local utility = chatVariables.utility

	local autofillModules = extensions.autofills
	local chatbar = chatVariables.uiObjects.chatbar.Chatbox
	
	local autofillBar = chatbar.Parent.AutofillBar

	local designFolder = chatVariables.designs

	local autofillContainer = chatVariables.uiObjects.autofill.Scroller
	local layout = autofillContainer.ListLayout
	
	local uiPadding = chatVariables.uiPadding
	
	local autofills = {}

	local security = function(fill)
		if(fill.security == "internal") then
			return chatVariables
		end
	end
	
	local getYPosition = function(button)
		local padding = ((button.LayoutOrder - 1) * 5)
		return padding + ((button.LayoutOrder - 1) * button.AbsoluteSize.Y)
	end

	local newButton = function()
		return designFolder.Button:Clone()
	end
	
	local inBounds = function(gui1,gui2) 
		local gui1_topLeft = gui1.AbsolutePosition
		local gui1_bottomRight = gui1_topLeft + gui1.AbsoluteSize
		local gui2_topLeft = gui2.AbsolutePosition
		local gui2_bottomRight = gui2_topLeft + gui2.AbsoluteSize
		return ((gui1_topLeft.x < gui2_bottomRight.x and gui1_bottomRight.x > gui2_topLeft.x) and (gui1_topLeft.y < gui2_bottomRight.y and gui1_bottomRight.y > gui2_topLeft.y))
	end

	local captureStrings = function(text, startsWith, endsWith)
		local matches = {}
		local found, beginAt = 1, 1

		repeat
			local startIdx, endIdx = text:find(startsWith, beginAt, true)

			if endIdx and (endIdx < #text) then
				-- Split remaining text on endsWith delimiter
				local remaining = text:sub(endIdx + 1, #text)
				local split = endsWith ~= "" and remaining:split(endsWith) or {remaining}

				local between = split[1]
				if #between:gsub(" ", "") >= 1 then  -- Check if there's non-space content
					table.insert(matches, {
						text = between,
						before = text:sub(1, startIdx - 1),
						hasClosing = (#split >= 2)  -- True if we found at least one endsWith delimiter
					})
				end
			end

			found = (endIdx and 1 or 0)
			beginAt = (endIdx and endIdx + 1 or beginAt)
		until(found == 0)

		return matches
	end

	local manager = {}
	local connections = {}
	local mapped = {}

	local currentlyInAutofill = false
	local selected = 0

	local choose = function(key)
		local option = mapped[key][2]
		autofillBar.Text = ""
		local current = chatbar.Text
		heartbeat:Wait() --> fixes some weird bug on mobile somehow 
		chatbar.Text = current:gsub(unpack(option.gsub))
	end

	local update = function()
		local selectedButton = mapped[selected][1]
		for _,data in pairs(mapped) do
			if(data[1] ~= selectedButton and data[1].BackgroundTransparency ~= 1) then
				data[1].BackgroundTransparency = 1
			end
		end
	end

	local onSelection = function(key,ignore)
		selected = key
		local data = mapped[key]
		local button,option = unpack(data)
				
		autofillBar.Text = option.autofillBar

		update()
		button.BackgroundTransparency = 0.5
				
		if not ignore then
			if not inBounds(autofillContainer,button) then
				autofillContainer.CanvasPosition = Vector2.new(0,getYPosition(button))
			end
		end
	end

	function manager:fill(options)
		autofillBar.Text = ""
		mapped = {}
		selected = 0

		autofillContainer.Parent.Visible = #options >= 1
		utility.clearChildrenOfClass(
			autofillContainer,"TextButton"
		)

		for key,connection in pairs(connections) do
			connection:Disconnect()
			table.remove(connections,key)
		end

		local hovering,lastHovering = nil,nil

		for key,option in pairs(options) do
			local button = newButton()
			button.Parent = autofillContainer
			button.Text = option.text
			button.BackgroundTransparency = 1
			button.LayoutOrder = key
			
			if option.image then
				local image;
				if typeof(option.image) == "function" then
					image = option.image(button)
				else
					image = option.image
				end
				if image then
					image.Parent = button
					image.Position = UDim2.fromOffset(button.TextBounds.X + 5,0)
				end
			end
			
			mapped[key] = {button,option}

			if(key == 1) then
				button.BackgroundTransparency = 0.5
				onSelection(key)
			end

			local signal,connection = utility.mouse:detectInObject(button)

			utility.store(connections,connection,signal:Connect(function(inside)
				if inside and (not ((button.AbsolutePosition.Y) >= (autofillContainer.AbsolutePosition.Y + autofillContainer.AbsoluteSize.Y))) then
					selected = key
					onSelection(key,true)
				end
				update()
			end),button.MouseButton1Click:Connect(function()
				choose(key)
			end))
		end
		
		autofillContainer.Parent.Size = UDim2.new(
			1,10,0,(layout.AbsoluteContentSize.Y + uiPadding * 2)
		)
	end

	local elapse = function(input,callback)
		task.spawn(function()
			local start = tick()
			repeat
				local elapsed = tick() - start
				callback()
				task.wait(0.25 - math.clamp(
					elapsed/10, 0, 0.1)
				)
			until(input.UserInputState == Enum.UserInputState.End)
		end)
	end
	
	local tabbed = 0;
	userInputService.InputBegan:Connect(function(input,gameProcessed)
		if #mapped > 0 then
			if input.KeyCode == Enum.KeyCode.Down then
				elapse(input,function()
					if selected + 1 <= #mapped then
						selected += 1
						onSelection(selected)
					end
				end)
			elseif input.KeyCode == Enum.KeyCode.Up then
				elapse(input,function()
					if selected - 1 >= 1 then
						selected -= 1
						onSelection(selected)
					end
				end)
			elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.Tab then
				if selected ~= 0 then
					choose(selected)
				end
			end
		end
	end)

	utility.mouse:detectInObject(autofillContainer):Connect(function(inside)
		currentlyInAutofill = inside
	end)

	local justReplaced;
	
	utility.onPropertyChanged(chatbar,"Size",function(newSize)
		autofillBar.Size = newSize
	end)
	
	local previous;
	utility.onPropertyChanged(chatbar,"Text",function(text)
		manager:fill({})
		if text ~= justReplaced then
			for _,fill in pairs(autofills) do
				local beginsWith,endsWith = fill.beginsWith,fill.endsWith
				local matches = captureStrings(text,beginsWith,endsWith)
				if(#matches > 0) then
					local wasReplaced = false
					local gsub,toFill,callback,endAt = fill.onCapture(matches,chatVariables)

					if(gsub) then
						for pattern,replace in pairs(gsub) do
							text = text:gsub(pattern,replace)
							wasReplaced = true
						end
						justReplaced = text
						if(wasReplaced) then
							heartbeat:Wait() --> fixes some weird bug on mobile somehow :shrug:
							chatbar.Text = text
						end
					end
					if(toFill) then
						manager:fill(toFill)
					end
					if(callback) then
						callback()
					end
					if endAt then
						chatbar.CursorPosition = endAt
					end

					break
				end
			end
		end
		previous = text
	end)

	utility.onChild(autofillModules,function(module)
		table.insert(autofills,require(module))
	end)
end

return {initialize = initialize}