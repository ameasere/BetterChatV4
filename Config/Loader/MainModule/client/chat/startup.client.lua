local players = game:GetService("Players")

local init = require(script.Parent.init)
local gui = require(script.Parent.Parent:WaitForChild("Chat"))()
local player = players.LocalPlayer
local playerGui = player.PlayerGui

gui.Parent = playerGui

local chat = init.start(
	gui
)

chat:systemMessage(
	chat.localization:localize("GameChat_ChatCommandsTeller_AllChannelWelcomeMessage")
)