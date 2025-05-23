local players = game:GetService("Players")
local textChatService = game:GetService("TextChatService")
local httpService = game:GetService("HttpService")

local onPlayer = function(callback)
	for _,player in pairs(players:GetPlayers()) do
		task.spawn(callback,player)
	end
	return players.PlayerAdded:Connect(callback)
end


local initialize = function(sharedVariables)
	local channelConstructor = {}
	local network = sharedVariables.network
	local richText = sharedVariables.richText
	
	local list = {}
	local reconstructors = {}
	
	local addUserToChannel = function(channel,userId)
		local textSource,hadToCreate = channel.object:AddUserAsync(userId)
		if textSource then
			channel.textSources[userId] = {
				since = os.time(),
				source = textSource,
				object = channel.object
			}
			textSource.CanSend = true
			channel.sourceAdded:Fire(userId,textSource)
			network:update("getChannelsIn",userId)
		end
	end
		
	function channelConstructor.new(name,autoJoin)
		local channel = {}
		channel.connections = {}
		channel.textSources = {}
		channel.name = name
		
		channel.sourceAdded = sharedVariables.signal.new()
		channel.sourceRemoved = sharedVariables.signal.new()
		
		table.insert(list,channel)

		local object = Instance.new("TextChannel")
		object.Name = name
		object.Parent = sharedVariables.channelFolder
		
		channel.object = object
		
		local messages = {}
		
		object.ShouldDeliverCallback = function(message,source)
			local success,metadata = pcall(function()
				return httpService:JSONDecode(message.Metadata)
			end)
			if metadata then
				if metadata.original then
					local text = richText:escape(metadata.original:sub(1,1000))
					local parsed = richText:markdown(text)
					local stripped = richText:strip(parsed)
					if(stripped == message.Text) then
						local _,reconstruct = richText:processForFilter(parsed)
						reconstructors[message.MessageId] = reconstruct
					end
				end
			end
			return true
		end
		
		function channel:Destroy()
			object:Destroy()
			for _,connection in pairs(channel.connections) do
				connection:Disconnect()
			end
		end
				
		table.insert(channel.connections,onPlayer(function(player)
			if autoJoin then
				addUserToChannel(channel,player.UserId)
			end
		end))
		
		table.insert(channel.connections,players.PlayerRemoving:Connect(function(player)
			if channel.textSources[player.UserId] then
				channel.sourceRemoved:Fire(player.UserId)
				channel.textSources[player.UserId] = nil
			end
		end))
				
		return channel
	end
	
	network.newUpdater("getChannelsIn",function(player)
		local channelsList = {}
		for _,channel in pairs(list) do
			if channel.textSources[player.UserId] then
				table.insert(channelsList,channel.textSources[player.UserId])
			end
		end
		table.sort(channelsList,function(a,b)
			return a.since < b.since
		end)
		local toReturn = {}
		for _,channel in pairs(channelsList) do
			table.insert(toReturn,channel.object)
		end
		return toReturn
	end)
	
	local callback = function(text)
		return text
	end
	
	network.newFunction("reconstruct",function(player,messageId,filteredText)
		return (reconstructors[messageId] or callback)(filteredText)
	end)
	
	sharedVariables.network.newEvent("reactToMessage",function(player,messageId,reaction)
		if reconstructors[messageId] then
			sharedVariables.network:fireClients("reactToMessage","all",{
				player = player,
				messageId = messageId,
				reactionEmoji = reaction
			})
		end
	end)
	
	return channelConstructor
end

return {initialize = initialize}