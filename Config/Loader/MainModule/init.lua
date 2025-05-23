local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local starterPlayer = game:GetService("StarterPlayer")

local initialize = function(config)
	-- init:
	
	local server = script.server
		
	-- base setup:
	
	local client = script.client
	client.Parent = starterPlayer.StarterPlayerScripts
	
	local sharedFolder = script.shared
	sharedFolder.Name = "betterchatv4shared"
	sharedFolder.Parent = replicatedStorage
	
	local sharedVariables = {}
	
	sharedVariables.signal = require(sharedFolder.signal)
	sharedVariables.network = require(sharedFolder.network)
	sharedVariables.richText = require(sharedFolder.formatting.richText)()
	sharedVariables.md5 = require(sharedFolder.md5)

	local channels = Instance.new("Folder")
	channels.Parent = textChatService
	channels.Name = "TextChannels"

	local systemChannel = Instance.new("TextChannel",channels)
	systemChannel.Name = "RBXSystem"
	
	sharedVariables.channelFolder = channels
	
	-- channel initializer:
	
	local channel = require(server.constructors.channel).initialize(sharedVariables)
	
	channel.new("Main",true)
	
	-- typing:
	
	sharedVariables.network.newFunction("getConfig",function()
		return config
	end)
	
	sharedVariables.network.newEvent("typingIndicator",function(player,state)
		if typeof(state) == "boolean" then
			sharedVariables.network:fireClients("typingIndicator","all",player,state)
		end
	end)
end

return {init = initialize}