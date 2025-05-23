-- Author: @Jumpathy
-- Name: main.lua
-- Description: Main chat bubble init

local initialize = function(chatVariables)
	local config = {
		EasingStyle = Enum.EasingStyle.Bounce, --> The chat bubble's tween style
		Length = 0.16, --> The length per tween in the UI
		MaxMessages = 4, --> The max amount of bubble chat messages above one user's head at once
		FadeoutTime = 10, --> Message fading time (set to false to disable automatic fade out)
		TextSize = 16, --> This is the chat bubble's text size.
		Padding = 8, --> Padding in offset on each side of the message.
		BubbleFont = Enum.Font.GothamMedium, --> The chat bubble's primary font.
		TypingIndicatorColor = Color3.fromRGB(255,255,255), --> Player typing indicator color.
		BubbleBackgroundColor = Color3.fromRGB(20,20,20), --> The chat bubble's background color.
		BubbleTextColor = Color3.fromRGB(255,255,255), --> The chat bubble's text color.
		Roundness = 8, --> The chat bubble's roundness in pixels
		MaxDistance = 40, --> How far away the bubble chat can be seen from?
	}

	-------------------------------------------

	local billboard = require(script:WaitForChild("billboard"))
	local utility = require(script:WaitForChild("utility"))

	local environment = {
		chatBubbles = {},
		stacks = {},
		config = {
			BubbleChat = {
				Config = config
			}
		},
		chatVariables = chatVariables
	}

	environment.tweenPosition = function(gui,endPosition,...)
		utility:tweenPropertiesInternal({
			["Position"] = endPosition
		},gui,...)
	end

	return billboard.init(config,environment)
end

return {
	initialize = initialize
}