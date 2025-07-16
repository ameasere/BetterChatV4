local userInputService = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")

local initialize = function(chatVariables)
	local chatbar = chatVariables.uiObjects.chatbar
	local additionalContext = chatVariables.uiObjects.additionalContext
	local utility = chatVariables.utility
	local channelBar = chatVariables.uiObjects.channelBar
	local window = chatVariables.uiObjects.window

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

		local sizeDifference = (scroller.Size - lastSize).Y.Offset
		
		additionalContext.Position = UDim2.fromOffset(0,
			chatbar.Position.Y.Offset + 35
		)
	
	end

	utility.onPropertyChanged(box,"Text",updateSizes)
	utility.updateSizes = updateSizes
	
end

return {initialize = initialize}
	