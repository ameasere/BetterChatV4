local config = require(script.Parent.Parent.Config)

local textChatService = game:GetService("TextChatService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local localPlayer = players.LocalPlayer

local group = config["GroupID"]

local messageId = 0


local initialize = function(chatVariables)
    local connected = {}
    local mapped = {}
    local modifiers = {}
    local history = {}

    local network = chatVariables.network

    local getMetadata = function(message)
        return httpService:JSONDecode(message.Metadata or "[]")
    end

    local verifyValidity = function(current,editing)
        return current:split("-")[1] == editing:split("-")[1] 
    end

    function chatVariables:newMessageId()
        messageId += 1
        return messageId
    end

    local getFrom = function(message)
        local metadata = getMetadata(message)
        local userId = message.TextSource.UserId
        local player = players:GetPlayerByUserId(userId)
        if player then
            messageId += 1
            mapped[message.MessageId] = messageId
            local replyingTo = metadata.context.replyingTo
            local isReply = nil
            if replyingTo then
                replyingTo = chatVariables.createMessage:guidToId(replyingTo)
                isReply = true
            else
                isReply = false
            end
            local usernameSender = player.DisplayName
            local playerTag = ""
            local team = player.Team
            local fontColor = team and team.TeamColor.Color or Color3.new(1, 1, 1)
            if group then
                playerTag = player:GetRoleInGroup(group)

                -- Extract the role within brackets or assign "Guest" if no role
                playerTag = playerTag:match("%[(.-)%]") or "Guest"

                -- Remove the brackets
                playerTag = playerTag:gsub("%[", ""):gsub("%]", "")

                usernameSender = string.format("   %s", player.Name)
            end

            local modifier = chatVariables.createMessage.new({
                metadata = metadata,
                displayName = usernameSender,
                username = player.Name,
                isReply = isReply,
                tag = playerTag,
                id = messageId,
                guid = message.MessageId,
                text = message.Text,
                sentAt = message.Timestamp.UnixTimestamp,
                senderId = userId,
                replyingTo = replyingTo,
                object = message,
                nameColor = fontColor
            },true)			
            table.insert(history,modifier)
            -- If the message is coming from this client, then run the below, otherwise don't
            if message.TextSource.UserId == localPlayer.UserId then
                chatVariables.uiObjects.additionalContext.ContextLabel.Text = ""
                chatVariables.components.chatbar:unassign()
            end
            return modifier
        end
    end

    network:hookUpdater("getChannelsIn",function(list)
        chatVariables.currentChannelList = list
        chatVariables.uiObjects.channelBar.Visible = (#list > 1)
        if(#list == 1) then
            chatVariables.currentChannel = list[1]
        end
        for _,channel in pairs(list) do
            if not connected[channel] then
                connected[channel] = true
                channel.MessageReceived:Connect(function(message)
                    local metadata = getMetadata(message)
                    if metadata.context and metadata.context.editingMessage and verifyValidity(message.MessageId,metadata.context.editingMessage) then
                        if modifiers[metadata.context.editingMessage] then
                            local reconstructed = network:invoke("reconstruct",message.MessageId,message.Text)
                            chatVariables.events.onMessage:Fire(message,reconstructed)
                            modifiers[metadata.context.editingMessage]:setText(
                                `{reconstructed} <font color="rgb(200,200,200)">({chatVariables.localization:localize("Chat_Edited")})</font>`
                            )
                        end
                    else
                        if not modifiers[message.MessageId] then
                            modifiers[message.MessageId] = getFrom(message)
                        end
                        if message.Status == Enum.TextChatMessageStatus.Success then
                            chatVariables:checkScrollerPos()
                            local reconstructed = network:invoke("reconstruct",message.MessageId,message.Text)
                            chatVariables.events.onMessage:Fire(message,reconstructed)
                            modifiers[message.MessageId]:setText(
                                reconstructed
                            )
                        else

                            modifiers[message.MessageId]:delete()
                        end
                    end
                    chatVariables:checkScrollerPos()
                end)
            end
        end
    end)

    textChatService.SendingMessage:Connect(function(message)
        if(chatVariables.currentChannel and message.TextChannel.Name == chatVariables.currentChannel.Name) then
            local metadata = getMetadata(message)
            if metadata.context and metadata.context.editingMessage then
                return
            else
                local userId = message.TextSource.UserId
                local player = players:GetPlayerByUserId(userId)
                if player then
                    chatVariables:checkScrollerPos()
                    modifiers[message.MessageId] = getFrom(message)
                end
            end
        end
    end)

    network.onClientEvent("reactToMessage",function(data)
        --print("Reaction signal received.")
        if modifiers[data.messageId] then
            modifiers[data.messageId]:addReaction(data.player,data.reactionEmoji)
        end
    end)

    network.onClientEvent("deleteMessage", function(data)
        --print("Delete message signal received")
        if modifiers[data.messageId] then
            modifiers[data.messageId]:delete()
        end
    end)

    chatVariables.events.onMessage = chatVariables.signal.new()
end

return {init = initialize}