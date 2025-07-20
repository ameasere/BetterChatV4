local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local initialize = function(chatVariables)
	local scroller = chatVariables.uiObjects.messageScroller
	local window = chatVariables.uiObjects.window
    local chatbar = chatVariables.uiObjects.chatbar
    local additionalContext = chatVariables.uiObjects.additionalContext
    
	local box = chatbar.Chatbox
	local uiPadding = chatVariables.uiPadding
	
	local inChatbar = false
	
	local doFormat = function(number) -- written by: waves5217 (@https://devforum.roblox.com/t/help-with-floating-point-errors/2474289/3)
		local formatted = string.format("%.3f", number) --> omit to three decimals
		formatted = formatted:gsub("%.?0+$", "") --> remove the dot and trailing zeroes
		return tonumber(formatted)
	end
	


	chatVariables.checkScrollerPos = function(self,bypass,len)
		local difference = doFormat(scroller.CanvasPosition.Y) - doFormat(scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteSize.Y)
		if(difference < 1) then
			task.spawn(function()
				task.wait()
				chatVariables.utility:tween({scroller,(len or 0.25),{
					["CanvasPosition"] = Vector2.new(0,doFormat(scroller.AbsoluteCanvasSize.Y))
				}})
			end)
		end
	end
	
	local inWindow = false
	
	local getScrollerSize = function()
		return scroller.AbsoluteSize
	end
	
	local function scrollToBottom(scroller)
		local y = scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y
		scroller.CanvasPosition = Vector2.new(0, y)
		
	end
	
	local setState = function(state)
		local windowCorner = window:FindFirstChild("UICorner")
		

		local tweens = chatVariables.utility:tween(
			{window, 0.2, {
				BackgroundTransparency = state and 0.35 or 0.75,
				BackgroundColor3 = state and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(235, 235, 235),
				Size = state and UDim2.new(0.291, 0, 0.493, 0) or UDim2.new(0.273, 0, 0.224, 0),
			}},
			{chatbar, 0.2, {
				BackgroundTransparency = state and 0.5 or 0.75,
				BackgroundColor3 = state and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(235, 235, 235),
				Position = state and UDim2.fromScale(0, 1.05) or UDim2.fromScale(0, 1.1),
				Size = state and UDim2.new(1, 0, 0.085, 0) or UDim2.new(0.65, 0, 0.2, 0),
			}},
			{box, 0.2, {}},
			{scroller, 0.2, {
				ScrollBarThickness = state and uiPadding or 0,
				Size = state and UDim2.new(1, 0, 0.95, 0) or UDim2.new(1, 0, 0.95, 0),
			}},
			{windowCorner, 0.2, {
				CornerRadius = state and UDim.new(0.05, 0) or UDim.new(0.1, 0)
			}},
			{additionalContext, 0.2, {
				Position = state and UDim2.fromScale(0, 1.15) or UDim2.fromScale(0, 1.3),
				Size = state and UDim2.fromScale(0.8, 0.075) or UDim2.fromScale(0.75, 0.2),
				BackgroundColor3 = state and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(235, 235, 235),
				BackgroundTransparency = state and 0.5 or 0.75
			}}
		)
		

		-- on Scroller size change, run scrollToBottom
		scroller:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			scrollToBottom(scroller)
		end)
	end

	
	chatVariables.utility.mouse:detectInObject(window):Connect(function(state)
		inWindow = state
		-- If the mouse is in the chatbar, state should still be true
		if inChatbar == true then
			state = true
		end
		if(not box:IsFocused()) then
			setState(state)
		end
    end)
    
	chatVariables.utility.mouse:detectInObject(chatbar):Connect(function(state)
		inChatbar = state
		if(not box:IsFocused()) then
			setState(state)
		end
    end)
	
	chatVariables.setWindowState = setState
	box.Focused:Connect(function()
		setState(true)
	end)
	
	box.FocusLost:Connect(function()
		if not inWindow then
			setState(false)
		end
	end)
	
	setState(false)
end

return {initialize = initialize}