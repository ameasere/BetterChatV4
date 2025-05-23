local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local initialize = function(chatVariables)
	local scroller = chatVariables.uiObjects.messageScroller
	local window = chatVariables.uiObjects.window
	local chatbar = chatVariables.uiObjects.chatbar
	local box = chatbar.Chatbox
	local uiPadding = chatVariables.uiPadding
	
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
	
	local setState = function(state)
		chatVariables.utility:tween({window,0.2,{
			BackgroundTransparency = state and 0.75 or 1
		}},{chatbar,0.2,{
			BackgroundTransparency = state and 0 or 1,
		}},{box,0.2,{
			PlaceholderColor3 = state and Color3.fromRGB(178, 178, 178) or Color3.fromRGB(255,255,255) 
		}},{scroller,0.2,{
			ScrollBarThickness = state and uiPadding or 0
		}})
	end
	
	chatVariables.utility.mouse:detectInObject(window):Connect(function(state)
		inWindow = state
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