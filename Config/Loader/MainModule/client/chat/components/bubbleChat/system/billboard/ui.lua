-- Author: @Jumpathy
-- Name: ui.lua
-- Description: Making ui work :sunglo:

return {
	init = function(config,environment)
		local textService = game:GetService("TextService")
		local tweenService = game:GetService("TweenService")
		local runService = game:GetService("RunService")
		
		local padding = config.Padding
		local tweenInfo = TweenInfo.new(0.3,config.EasingStyle,Enum.EasingDirection.Out,0,true,0.3)
		local label = Instance.new("TextLabel")
        label.RichText = true
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new(0, 5, 0.5, 0)
		
		local getTextContent = function(text)
			label.Text = text
			return label.ContentText
		end
		
		local getBounds = function(text,font)
			return textService:GetTextSize(getTextContent(text),config.TextSize,(font or config.BubbleFont),Vector2.new(250,math.huge))
		end
		
		local pad = function(x,y)
			x += padding * 2
			y += padding * 2
			return x,y
		end
		
		local create = function(text,parent,font)
			local bounds = getBounds(text,font)
			local bubble,edge,label,caret = Instance.new("Frame"),Instance.new("UICorner"),Instance.new("TextLabel"),Instance.new("ImageLabel")
			
			bubble.Name = "bubble"
			bubble.AnchorPoint = Vector2.new(0.5,1)
			bubble.BackgroundColor3 = config.BubbleBackgroundColor
			bubble.Position = UDim2.new(0.5,0,0.9,0)
			bubble.Size = UDim2.fromOffset(pad(bounds.X,bounds.Y))

			edge.CornerRadius = UDim.new(0,12)
			edge.Name = "edge"
			edge.Parent = bubble
			
			label.Name = "Label"
			label.Parent = bubble
			label.AnchorPoint = Vector2.new(0.5,0.5)
			label.BackgroundColor3 = Color3.fromRGB(0,0,0)
			label.BackgroundTransparency = 1
			label.Position = UDim2.new(0.5,0,0.5,0)
			label.Size = UDim2.new(1,0,1,0)
			label.Font = font or config.BubbleFont
			label.Text = text
			label.TextColor3 = config.BubbleTextColor
			label.TextSize = config.TextSize
			label.TextWrapped = true
			label.RichText = true
			
			caret.Name = "caret"
			caret.Parent = bubble
			caret.AnchorPoint = Vector2.new(0.5,0)
			caret.BackgroundTransparency = 1
			caret.Position = UDim2.new(0.5,0,0.99,0)
			caret.Size = UDim2.new(0,5,0,5)
			caret.Image = "rbxasset://textures/ui/InGameChat/Caret.png"
			caret.ImageColor3 = config.BubbleBackgroundColor
			if(parent) then
				bubble.Parent = parent
			end
			
			return bubble
		end
		
		local newDot = function(x)
			local dot = Instance.new("Frame")
			local corner = Instance.new("UICorner")
			
			dot.Size = UDim2.fromOffset(x/8,x/8)
			dot.BackgroundColor3 = config.TypingIndicatorColor
			dot.Name = "TypingDot"
			dot:SetAttribute("TypingIndicator",true)
			
			corner.Parent = dot
			corner.CornerRadius = UDim.new(100,0)
			
			return dot
		end
		
		local animateIndicator = function(dots)
			-- recursive tweening bc the inf loop has undesirable behavior for me (after like 5 minutes of tweening they all line up for some reason)
			local base = {}
			local goals = {}
			
			for key,dot in pairs(dots) do
				if(dot:GetFullName() ~= dot.Name) then
					base[dot] = base[dot] or dot.Position
					local newPos = base[dot] - UDim2.fromOffset(0,5)
					goals[dot] = {
						startAt = base[dot],
						endAt = newPos
					}
				end
			end
			
			local lerp = function(a, b, t)
				return a + (b - a) * t
			end
						
			local customTween = function(object,length,goal,transparency)
				for i = 1,15 do
					local newPos = object.Position:Lerp(goal,i/15)
					object.Position = newPos
					object.BackgroundTransparency = lerp(math.min(transparency,object.BackgroundTransparency),math.max(transparency,object.BackgroundTransparency),i/15)
					task.wait(length/15)
				end
			end
			
			task.spawn(function()
				local doEnd = false
				while(not doEnd) do
					for key,dot in pairs(dots) do
						if(dot:GetFullName() ~= dot.Name) then
							customTween(dot,0.2,goals[dot]["endAt"],0.6)
							task.spawn(customTween,dot,0.2,goals[dot]["startAt"],0)
						else
							doEnd = true
							break
						end
					end
				end
			end)
		end
		
		local typingIndicator = function(parent)
			local bubble = create("......",nil,Enum.Font.GothamMedium)
			local dots = {}
			
			local xSize = bubble.AbsoluteSize.X
			bubble.Size += UDim2.fromOffset(15,0)
			bubble.Label:Destroy()
			
			local container = Instance.new("Frame")
			container.Parent = bubble
			container.Size = UDim2.fromScale(1,0.5)
			container.Position = UDim2.fromScale(0.5,0.5)
			container.AnchorPoint = Vector2.new(0.5,0.5)
			container.BackgroundTransparency = 1
			
			local layout = Instance.new("UIListLayout")
			layout.Parent = container
			layout.Padding = UDim.new(0,5)
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			layout.FillDirection = Enum.FillDirection.Horizontal
			
			for i = 1,3 do
				local dot = newDot(xSize)
				dot.Parent = container
				dot.Name = i
				dots[i] = dot
			end
			
			for _,dot in pairs(dots) do
				dot.AnchorPoint = Vector2.new(0,0.5)
				dot.Position = UDim2.new(0,dot.AbsolutePosition.X,0.5,0)
			end
			
			layout:Destroy()
			animateIndicator(dots)
			
			bubble.Parent = parent
			return bubble
		end
		
		local billboard = function(name,player)
			local billboard = Instance.new("BillboardGui")
			local container = Instance.new("Frame")
			
			billboard.Name = name
			billboard.Active = true
			billboard.MaxDistance = config.MaxDistance or 40
			billboard.Size = UDim2.new(20, 0, 20, 0)
			billboard.StudsOffset = Vector3.new(0, 9.5, 2)
			
			container.Name = "Container"
			container.Parent = billboard
			container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			container.BackgroundTransparency = 1.000
			container.Size = UDim2.new(1, 0, 1, 0)
			return billboard
		end
		
		return {
			bubble = {
				new = function(text,parent,font,message)
					local bubble = create(text,parent,font,message)
					
					local constraint = Instance.new("UISizeConstraint")
					constraint.MaxSize = Vector2.new(math.huge,200)
					constraint.Parent = bubble.Label
					
					bubble.Label.Size = UDim2.new(0,200,0,200)
					
					environment.chatVariables.customEmojiHandler:setText(bubble.Label,text,message)
					
					local contentSize = bubble.Label.Layout.AbsoluteContentSize
					
					local x,y = math.ceil(contentSize.X),math.ceil(contentSize.Y)
					bubble.Label.Size = UDim2.fromOffset(x,y)
					bubble.Label.Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
										
					bubble.Size = UDim2.fromOffset(pad(x,y))
					return bubble
				end,
			},
			typingIndicator = {
				new = typingIndicator
			},
			billboard = {
				new = billboard
			}
		}
	end,
}