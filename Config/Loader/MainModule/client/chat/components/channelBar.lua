local initialize = function(chatVariables)
	local chatbar = chatVariables.uiObjects.chatbar
	local channelBar = chatVariables.uiObjects.channelBar
	local scroller = chatVariables.uiObjects.messageScroller

	local utility = chatVariables.utility
	local padding = chatVariables.uiPadding
	
	utility.onPropertyChanged(channelBar,"Visible",utility.updateSizes)
end

return {initialize = initialize}