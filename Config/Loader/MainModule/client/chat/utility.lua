local contentProvider = game:GetService("ContentProvider")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")

local initialize = function(chatVariables)
	local mouse = require(script.Parent.modules.mouse).initialize(chatVariables)
	local utility = {}
	
	utility.getScrollerSize = function()
		return chatVariables.uiObjects.messageScroller.AbsoluteSize
	end

	utility.getThumbnailFromId = function(id)
		return `rbxthumb://type=AvatarHeadShot&id={id}&w=48&h=48`
	end
	
	utility.handleChildrenOfClass = function(object,class,callback)
		for _,child in pairs(object:GetChildren()) do
			if(child:IsA(class)) then
				callback(child)
			end
		end
	end
	
	utility.handleChildrenOfClasses = function(object,classes,callback)
		for _,class in pairs(classes) do
			for _,child in pairs(object:GetChildren()) do
				if child:IsA(class) then
					callback(child)
				end
			end
		end
	end

	utility.clearChildrenOfClass = function(object,class)
		for _,child in pairs(object:GetChildren()) do
			if(child:IsA(class)) then
				child:Destroy()
			end
		end
	end

	utility.onPropertyChanged = function(object,property,callback)
		local signal = object:GetPropertyChangedSignal(property):Connect(function()
			callback(object[property])
		end)
		task.spawn(callback,object[property])
		return signal
	end
	
	utility.getTextBoundsFromObject = function(object,maxWidth)
		local params = Instance.new("GetTextBoundsParams")
		params.Text = object.Text
		params.Font = object.FontFace
		params.Size = object.TextSize
		params.Width = maxWidth
		return textService:GetTextBoundsAsync(params)
	end
	
	utility.onChild = function(object,callback)
		for _,child in pairs(object:GetChildren()) do
			task.spawn(callback,child)
		end
		object.ChildAdded:Connect(callback)
	end
	
	utility.onDescendantOfClasses = function(object,classes,callback)
		local check = function(descendant)
			for _,class in pairs(classes) do
				if descendant:IsA(class) then
					callback(descendant)
					break
				end
			end
		end
		for _,descendant in pairs(object:GetDescendants()) do
			task.spawn(check,descendant)
		end
		object.DescendantAdded:Connect(check)
	end
	
	function utility:tween(...)
		local style = Enum.EasingStyle.Linear
		local args = {...}
		if(type(args[1]) ~= "table") then
			local object,length,properties,direction,overStyle = unpack(args)
			local tween = tweenService:Create(object,TweenInfo.new(length,overStyle or style,direction or Enum.EasingDirection.Out),properties)
			tween:Play()
			return tween
		else
			local tweens = {}
			for _,t in pairs(args) do
				local object,length,properties,direction,overStyle = unpack(t)
				local tween = tweenService:Create(object,TweenInfo.new(length,overStyle or style,direction or Enum.EasingDirection.Out),properties)
				tween:Play()
				tweens[object] = tween
			end
			return tweens
		end
	end
	
	function utility.store(tbl,...)
		for _,v in pairs({...}) do
			table.insert(tbl,v)
		end
	end
	
	utility.mouse = mouse
	
	local customEmojis = chatVariables.config.CustomEmojis
	
	local onPlayer = function(player)
		if true then -- iconsEnabled
			local image = Instance.new("ImageLabel")
			image.Image = utility.getThumbnailFromId(player.UserId)
			contentProvider:PreloadAsync({image})
			image:Destroy()
		end
	end
	
	players.PlayerAdded:Connect(onPlayer)
	for _,player in pairs(players:GetPlayers()) do
		task.spawn(onPlayer,player)
	end
	
	for _,customEmoji in pairs(customEmojis) do
		task.spawn(function()
			local image = Instance.new("ImageLabel")
			image.Image = customEmoji
			contentProvider:PreloadAsync({image})
		end)
	end
	
	local getNameValue = function(name)
		local value = 0
		local nameLength = string.len(name)
		for i = 1,nameLength do
			local charValue = string.byte(name:sub(i,i))
			local reverseIndex = nameLength - i + 1
			if(nameLength % 2 == 1) then
				reverseIndex -= 1
			end
			if(reverseIndex % 4 >= 2) then
				charValue = -charValue
			end
			value += charValue
		end
		return value
	end

	local nameColors = { --> Default name colors
		Color3.fromRGB(253,41,67), --> Red
		Color3.fromRGB(1,162,255), --> Blue
		Color3.fromRGB(1,236,111), --> Green
		Color3.fromRGB(180,128,255), --> Purple
		Color3.fromRGB(255,154,76), --> Orange
		Color3.fromRGB(255,211,50), --> Yellow
		Color3.fromRGB(255,205,221), --> Pink
		Color3.fromRGB(255,234,183) --> Beige
	}

	function utility:getNameColor(name)
		return nameColors[((getNameValue(name)) % #nameColors) + 1]
	end
	
	return utility
end

return {initialize = initialize}