local utility = {}
local tweenService = game:GetService("TweenService")
local style = Enum.EasingStyle.Linear

function utility:tween(...)
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

local default = function() end

function utility:tweenPropertiesInternal(properties,gui,easingDirection,easingStyle,length,override,callback)
	utility:tween(
		gui,
		length or 1,
		properties,
		easingDirection or Enum.EasingDirection.Out,
		easingStyle or Enum.EasingStyle.Linear
	).Completed:Once(callback or default)
end

return utility