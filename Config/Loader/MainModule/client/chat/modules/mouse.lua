local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local guiService = game:GetService("GuiService")

local initialize = function(chatVariables)	
	local signal = chatVariables.signal
	
	local mouseMoved = signal.new()
	
	local mouse = {}
	mouse.mouseMoved = mouseMoved
	
	function mouse:detectInObject(object,wrapper)
		local detector = signal.new()
		local state = false
		local connection = mouse.mouseMoved:Connect(function(newPosition)
			local currentlyInside = false
			local aP,aS = object.AbsolutePosition,object.AbsoluteSize
			if newPosition.X >= aP.X and newPosition.X <= aP.X + aS.X then
				if newPosition.Y >= aP.Y and newPosition.Y <= aP.Y + aS.Y then
					currentlyInside = true
				end
			end
			if state ~= currentlyInside then
				local send = true
				if wrapper then
					send = wrapper()
				end
				if send then
					state = currentlyInside
					detector:Fire(state)
				end
			end
		end)
		return detector,connection
	end
	
	local oldMousePos;
	runService.Heartbeat:Connect(function()
		local newMousePos = userInputService:GetMouseLocation()
		if newMousePos ~= oldMousePos then
			local inset = guiService:GetGuiInset()
			oldMousePos = newMousePos
			mouseMoved:Fire(
				newMousePos - inset
			)
		end
	end)
	
	function mouse:getPosition()
		local inset = guiService:GetGuiInset()
		return userInputService:GetMouseLocation() - inset
	end

	return mouse
end

return {initialize = initialize}