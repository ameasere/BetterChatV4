local initialize = function(chatVariables)
	local bubbleChat = require(script.system).initialize(chatVariables)
	local network = chatVariables.network
	local players = game:GetService("Players")
	local httpService = game:GetService("HttpService")
	local controllers = {}
	
	local getController = function(sender)
		local controller = controllers[sender]
		if not controller then
			local i = 0
			repeat
				i += 1
				task.wait()
				controller = controllers[sender]
			until(i > 1000 or controller)
		end
		return controller
	end
	
	local onCharacter = function(player,character)
		local head = character:WaitForChild("Head",8)
		if head then
			local controller = bubbleChat:create(head)
			controllers[player] = controller
		end
	end
	
	local onPlayer = function(player)
		player.CharacterAdded:Connect(function(character)
			onCharacter(player,character)
		end)
		if player.Character then
			task.spawn(onCharacter,player,player.Character)
		end
	end

	players.PlayerAdded:Connect(onPlayer)
	for _,player in pairs(players:GetPlayers()) do
		task.spawn(onPlayer,player)
	end
	
	network.onClientEvent("typingIndicator",function(player,state)
		if controllers[player] then
			controllers[player]:setTypingIndicatorVisible(state)
		end
	end)
	
	chatVariables.events.onMessage:Connect(function(messageObject,reconstructedText)
		local sender = players:GetPlayerByUserId(messageObject.TextSource.UserId)
		if sender then
			local controller = getController(sender)
			if controller then
				controller:createMessage(reconstructedText,messageObject)
			end
		end
	end)
end

return {initialize = initialize}