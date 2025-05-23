local chatFolder = script.Parent
local replicatedStorage = game:GetService("ReplicatedStorage")
local sharedFolder = replicatedStorage:WaitForChild("betterchatv4shared")

local richText = require(sharedFolder.formatting.richText)()

local textChatService = game:GetService("TextChatService")
local players = game:GetService("Players")

local initialize = function(gui)
	local mainWindow = gui.Main
	local chatbar = mainWindow.Chatbar
	local scrollingFrame = mainWindow.Scroller
	local channelBar = mainWindow.Channelbar
	
	local messageCreators = chatFolder.messageCreators
	local components = chatFolder.components
	local eventHandler = chatFolder.modules.eventHandler
	local connectionsModule = chatFolder.modules.coreConnections
	
	local chatVariables = {
		chatUi = gui,
		uiPadding = 5,
		
		designs = components.designs,
		extensions = chatFolder.extensions,
		
		uiObjects = {
			messageScroller = scrollingFrame,
			chatbar = chatbar,
			channelBar = channelBar,
			window = mainWindow,
			autofill = mainWindow.Autofill,
			contextMenu = mainWindow.Parent.ContextMenu
		},
		
		configurations = {
			chatbarConfiguration = textChatService.ChatInputBarConfiguration,
			chatWindowConfiguration = textChatService.ChatWindowConfiguration,
			bubbleChatConfiguration = textChatService.BubbleChatConfiguration
		},
		
		components = {},
		events = {},
		
		richText = richText
	}
	
	
	local connections = require(connectionsModule)
	
	chatVariables.connections = connections
	
	chatVariables.localization = require(chatFolder.localization.master)()
	chatVariables.xml = require(sharedFolder.xml)
	chatVariables.signal = require(sharedFolder.signal)
	chatVariables.network = require(sharedFolder.network)
	chatVariables.config = chatVariables.network:invoke("getConfig")
	chatVariables.utility = require(chatFolder.utility).initialize(chatVariables)
	chatVariables.customEmojiHandler = require(chatFolder.modules.customEmojiHandler).initialize(chatVariables)
	chatVariables.createMessage = require(messageCreators.defaultMessage).initialize(chatVariables)
	chatVariables.components.chatbar = require(components.chatbar).initialize(chatVariables)
	chatVariables.components.autofills = require(components.autofill).initialize(chatVariables)
	chatVariables.components.channelBar = require(components.channelBar).initialize(chatVariables)
	chatVariables.components.chatWindow = require(components.chatWindow).initialize(chatVariables)
	
	require(eventHandler).init(chatVariables)
	chatVariables.components.bubbleChat = require(components.bubbleChat).initialize(chatVariables)
	
	local chatOpenState = true
	
	local toggleChatState = function()
		connections:Fire("ChatWindow","VisibilityStateChanged",(not chatOpenState))
		chatOpenState = not chatOpenState
		mainWindow.Visible = chatOpenState
	end
	
	function chatVariables:getChatOpenState()
		return chatOpenState
	end

	chatVariables.utility.onDescendantOfClasses(mainWindow,{"TextLabel","TextButton","TextBox"},function(descendant)
		descendant.FontFace = chatVariables.configurations.chatWindowConfiguration.FontFace
		descendant.TextSize = chatVariables.configurations.chatWindowConfiguration.TextSize
	end)

	connections:Connect("ChatWindow","ToggleVisibility",toggleChatState)
	
	function chatVariables:systemMessage(text)
		return chatVariables.createMessage.new({
			npc = true,
			displayName = chatVariables.localization:localize("InGame.Chat.Label.SystemMessagePrefix"),
			text = text,
			nameColor = Color3.fromRGB(200,200,200),
			icon = {
				Image = "rbxassetid://6034287594",
				BackgroundTransparency = 1
			},
			disableBubbling = true
		},false)
	end
	
	if true then -- FriendJoinNotifier
		local onFriendJoin = function(username)
			chatVariables:systemMessage(
				chatVariables.localization:localize("GameChat_FriendChatNotifier_JoinMessage"):format(username)
			)
		end
		
		players.PlayerAdded:Connect(function(player)
			pcall(function()
				if player:IsFriendsWith(players.LocalPlayer.UserId) then
					onFriendJoin(player.DisplayName)
				end
			end)
		end)
	end
	
	return chatVariables
end

return {start = initialize}