local network = {}
local eventHolder = script

local players = game:GetService("Players")

-- server

function network.newEvent(name,callback)
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = eventHolder
	event.OnServerEvent:Connect(callback)
end

function network.newFunction(name,callback)
	local event = Instance.new("RemoteFunction")
	event.Name = name
	event.Parent = eventHolder
	event.OnServerInvoke = callback
end

function network:fireClients(name,clients,...)
	local event = eventHolder[name]
	if(clients ~= "all") then
		for _,client in pairs(clients) do
			event:FireClient(client,...)
		end
	else
		event:FireAllClients(...)
	end
end

local internal = {}

function network.newUpdater(name,request)
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = eventHolder

	event.OnServerEvent:Connect(function(player)
		event:FireClient(player,request(player))
	end)

	internal[name] = request
end

function network:update(name,player)
	if(typeof(player) == "number") then
		player = players:GetPlayerByUserId(player)
	end
	eventHolder[name]:FireClient(player,internal[name](player))
end

-- client

function network:invoke(name,...)
	local event = eventHolder:WaitForChild(name,8)
	return event:InvokeServer(...)
end

function network:fire(name,...)
	local event = eventHolder:WaitForChild(name,8)
	return event:FireServer(...)
end

function network.onClientEvent(name,callback)
	local event = eventHolder:WaitForChild(name,8)
	event.OnClientEvent:Connect(callback)
end

function network:hookUpdater(name,callback)
	local event = eventHolder:WaitForChild(name,8)
	event.OnClientEvent:Connect(callback)
	event:FireServer()
end

return network