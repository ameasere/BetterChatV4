-- Author: @Jumpathy
-- Name: billboard.lua
-- Description: Billboard gui for bubble chat lol
-- Small credits:
-- @McThor2 - [Math help](https://devforum.roblox.com/t/raycast-between-2-attachments/976915/8)
-- @sleitnick - [Raycasting help](https://devforum.roblox.com/t/detect-if-player-is-looking-at-object/1479746/5)

local billboard = {}
local useRaycastingToDetermineVisibility = true
local collectionService = game:GetService("CollectionService")
local connections = {}

local onDescendant = function(object,callback)
	for _,descendant in pairs(object:GetDescendants()) do
		task.spawn(callback,descendant)
	end
	return object.DescendantAdded:Connect(callback)
end

function billboard.init(config,environment)
	local httpService = game:GetService("HttpService")
	
	local ui = require(script:WaitForChild("ui")).init(config,environment)
	local stackModule = require(script.Parent:WaitForChild("stack"))(environment).init(config)
	local padding = config.Padding
	local camera = workspace.CurrentCamera
	local billboardData = {}

	local players = game:GetService("Players")
	local localPlayer = players.LocalPlayer

	local containerGui = Instance.new("ScreenGui")
	containerGui.Name = "bubbleChat"
	containerGui.Parent = localPlayer.PlayerGui
	containerGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	containerGui.ResetOnSpawn = false
	environment.bubbleChatContainer = containerGui

	local linkAlwaysOnTop = function(gui,adornee)
		local raycastParams = RaycastParams.new()
		raycastParams.IgnoreWater = true
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {adornee.Parent}
		billboardData[gui] = {
			adornee = adornee,
			params = raycastParams
		}
	end

	camera.Changed:Connect(function()
		pcall(function()
			for gui,billboard in pairs(billboardData) do
				if gui:GetFullName() == gui.Name then
					billboardData[gui] = nil
				else
					if(billboard.adornee and not gui.Adornee) then
						gui.Adornee = billboard.adornee
					end
					local result = (billboard.adornee.Position - camera.CFrame.Position)
					if(result.magnitude < gui.MaxDistance) then
						local vector,inViewport = camera:WorldToViewportPoint(billboard.adornee.Position)
						local onScreen = inViewport and vector.Z > 0
						if(onScreen) then
							local raycastResult = workspace:Raycast(camera.CFrame.Position,result,billboard.params)
							gui.AlwaysOnTop = not raycastResult
						else
							gui.AlwaysOnTop = false
						end
					end
				end
			end
		end)
	end)

	function billboard:create(part,adornee,options)
		options = options or {}
		local gui = ui.billboard.new(httpService:GenerateGUID())
		gui.Parent = containerGui
		gui.Adornee = adornee or part
		gui.StudsOffset = Vector3.new(0,10.5,0.1)

		local typingIndicator = ui.typingIndicator.new(gui.Container)
		typingIndicator.Visible = false

		if(useRaycastingToDetermineVisibility) then
			linkAlwaysOnTop(gui,gui.Adornee)
		end

		local objs = {}

		local bubbleBackgroundColor = config.BubbleBackgroundColor
		local typingIndicatorColor = config.TypingIndicatorColor
		local bubbleTextColor = config.BubbleTextColor

		local newColor = function(obj,propertyName)
			local bgColor = bubbleBackgroundColor
			local indicatorColor = typingIndicatorColor
			local textColor = bubbleTextColor

			if(obj and obj:GetFullName() ~= obj.Name) then
				if obj:GetAttribute("TypingIndicator") then
					obj[propertyName] = indicatorColor
				else
					local success,hasText = pcall(function()
						return obj.Text
					end)
					if success then
						obj["TextColor3"] = textColor
					else
						obj[propertyName] = bgColor
					end
				end
			else 
				objs[obj] = nil
			end
		end

		onDescendant(gui,function(object)
			pcall(function()
				if object.BackgroundColor3 then
					objs[object] = "BackgroundColor3"
					if object.ImageColor3 and not object:GetAttribute("IsEmoji") then
						objs[object] = "ImageColor3"
					end
				end
			end)
			if objs[object] then
				newColor(object,objs[object])
			end
		end)

		local update = function()
			for obj,property in pairs(objs) do
				newColor(obj,property)
			end
		end

		local stack = stackModule.new(gui,{
			FadeoutTime = options.FadeoutTime or config.FadeoutTime,
			MaxMessages = options.MaxMessages or config.MaxMessages,
			EasingStyle = options.EasingStyle or config.EasingStyle,
			Length = options.Length or config.Length
		})

		local lastState = false

		return {
			createMessage = function(self,text,message)
				local revisible = false
				if lastState then
					revisible = true
					self:setTypingIndicatorVisible(false)
				end
				local guid = httpService:GenerateGUID()
				local bubble = ui.bubble.new(text,gui.Container,nil,message)
				environment.chatBubbles[guid] = bubble
				environment.stacks[guid] = stack
				stack:push(
					bubble,false,guid					
				)
				if revisible then
					self:setTypingIndicatorVisible(true)
				end
				return {
					fadeOut = function()
						stack:fade(bubble)
						stack:remove(bubble)
					end
				}
			end,
			setColors = function(self,colors)
				bubbleBackgroundColor = colors.BubbleBackgroundColor or bubbleBackgroundColor
				typingIndicatorColor = colors.TypingIndicatorColor or typingIndicatorColor
				bubbleTextColor = colors.BubbleTextColor or bubbleTextColor
				update()
			end,
			setTypingIndicatorVisible = function(self,state)
				typingIndicator.Visible = state
				if(lastState ~= state) then
					lastState = state
					if(state) then
						stack:push(typingIndicator,true)
					else
						stack:remove(typingIndicator)
					end
				end
			end,
			getUi = function()
				return gui
			end,
		}
	end
	
	return billboard
end

return billboard