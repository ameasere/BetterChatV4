return function()
	
	local chat = Instance.new("ScreenGui")
	chat.Name = "Chat"
	chat.ResetOnSpawn = false

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	main.BackgroundTransparency = 0.75
	main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	main.BorderSizePixel = 0
	main.Size = UDim2.fromOffset(400, 330)

	local padding = Instance.new("UIPadding")
	padding.Name = "Padding"
	padding.PaddingBottom = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 5)
	padding.PaddingRight = UDim.new(0, 5)
	padding.PaddingTop = UDim.new(0, 5)
	padding.Parent = main

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroller"
	scroller.Active = true
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	scroller.BackgroundTransparency = 1
	scroller.BorderColor3 = Color3.fromRGB(0, 0, 0)
	scroller.BorderSizePixel = 0
	scroller.BottomImage = "rbxassetid://8082116996"
	scroller.CanvasSize = UDim2.new()
	scroller.MidImage = "rbxassetid://7488333553"
	scroller.Position = UDim2.fromOffset(0, 35)
	scroller.ScrollBarThickness = 5
	scroller.Size = UDim2.fromScale(1, 0)
	scroller.TopImage = "rbxassetid://8082122989"

	local listLayout = Instance.new("UIListLayout")
	listLayout.Name = "ListLayout"
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scroller

	scroller.Parent = main

	local uICorner = Instance.new("UICorner")
	uICorner.Name = "UICorner"
	uICorner.Parent = main

	local chatbar = Instance.new("Frame")
	chatbar.Name = "Chatbar"
	chatbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	chatbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	chatbar.BorderSizePixel = 0
	chatbar.Position = UDim2.fromOffset(0, 150)
	chatbar.Size = UDim2.new(1, 0, 0, 25)

	local uICorner1 = Instance.new("UICorner")
	uICorner1.Name = "UICorner"
	uICorner1.Parent = chatbar

	local chatbox = Instance.new("TextBox")
	chatbox.Name = "Chatbox"
	chatbox.AnchorPoint = Vector2.new(1, 0)
	chatbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	chatbox.BackgroundTransparency = 1
	chatbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	chatbox.BorderSizePixel = 0
	chatbox.ClearTextOnFocus = false
	chatbox.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	chatbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	chatbox.PlaceholderText = "Type \"\\\" or tap to chat"
	chatbox.Position = UDim2.fromScale(1, 0)
	chatbox.Size = UDim2.fromScale(1, 1)
	chatbox.Text = ""
	chatbox.TextColor3 = Color3.fromRGB(0, 0, 0)
	chatbox.TextSize = 13
	chatbox.TextWrapped = true
	chatbox.TextXAlignment = Enum.TextXAlignment.Left
	chatbox.ZIndex = 3
	
	chatbox.Changed:Connect(function()
		chatbox.Text = chatbox.Text:sub(1,120)
	end)

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 5)
	uIPadding.PaddingRight = UDim.new(0, 5)
	uIPadding.Parent = chatbox

	chatbox.Parent = chatbar

	local autofillBar = Instance.new("TextLabel")
	autofillBar.Name = "AutofillBar"
	autofillBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	autofillBar.BackgroundTransparency = 1
	autofillBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	autofillBar.BorderSizePixel = 0
	autofillBar.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	autofillBar.Size = UDim2.fromScale(1, 1)
	autofillBar.Text = ""
	autofillBar.TextColor3 = Color3.fromRGB(200, 200, 200)
	autofillBar.TextSize = 13
	autofillBar.TextWrapped = true
	autofillBar.TextXAlignment = Enum.TextXAlignment.Left
	autofillBar.ZIndex = 2

	local uIPadding1 = Instance.new("UIPadding")
	uIPadding1.Name = "UIPadding"
	uIPadding1.PaddingLeft = UDim.new(0, 5)
	uIPadding1.PaddingRight = UDim.new(0, 5)
	uIPadding1.Parent = autofillBar

	autofillBar.Parent = chatbar

	local actionIcon = Instance.new("ImageButton")
	actionIcon.Name = "ActionIcon"
	actionIcon.BackgroundColor3 = Color3.fromRGB(253, 80, 111)
	actionIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	actionIcon.BorderSizePixel = 0
	actionIcon.Position = UDim2.fromOffset(5, 5)
	actionIcon.Size = UDim2.fromOffset(20, 20)
	actionIcon.Visible = false

	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "UICorner"
	uICorner2.Parent = actionIcon

	local img = Instance.new("ImageLabel")
	img.Name = "Img"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	img.BackgroundTransparency = 1
	img.BorderColor3 = Color3.fromRGB(0, 0, 0)
	img.BorderSizePixel = 0
	img.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromScale(0.85, 0.85)
	img.Parent = actionIcon

	actionIcon.Parent = chatbar

	chatbar.Parent = main

	local channelbar = Instance.new("Frame")
	channelbar.Name = "Channelbar"
	channelbar.AutomaticSize = Enum.AutomaticSize.Y
	channelbar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	channelbar.BackgroundTransparency = 0.75
	channelbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	channelbar.BorderSizePixel = 0
	channelbar.Size = UDim2.fromScale(1, 0)
	channelbar.Visible = false

	local uICorner3 = Instance.new("UICorner")
	uICorner3.Name = "UICorner"
	uICorner3.Parent = channelbar

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Padding = UDim.new(0, 5)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Parent = channelbar

	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.Name = "UIPadding"
	uIPadding2.PaddingBottom = UDim.new(0, 5)
	uIPadding2.PaddingLeft = UDim.new(0, 5)
	uIPadding2.PaddingRight = UDim.new(0, 5)
	uIPadding2.PaddingTop = UDim.new(0, 5)
	uIPadding2.Parent = channelbar

	local textButton = Instance.new("TextButton")
	textButton.Name = "TextButton"
	textButton.AutomaticSize = Enum.AutomaticSize.XY
	textButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	textButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textButton.BorderSizePixel = 0
	textButton.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	textButton.Text = "Main"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 13

	local uIPadding3 = Instance.new("UIPadding")
	uIPadding3.Name = "UIPadding"
	uIPadding3.PaddingBottom = UDim.new(0, 5)
	uIPadding3.PaddingLeft = UDim.new(0, 5)
	uIPadding3.PaddingRight = UDim.new(0, 5)
	uIPadding3.PaddingTop = UDim.new(0, 5)
	uIPadding3.Parent = textButton

	local uICorner4 = Instance.new("UICorner")
	uICorner4.Name = "UICorner"
	uICorner4.CornerRadius = UDim.new(0, 5)
	uICorner4.Parent = textButton

	textButton.Parent = channelbar

	channelbar.Parent = main

	local autofill = Instance.new("Frame")
	autofill.Name = "Autofill"
	autofill.AnchorPoint = Vector2.new(0.5, 0)
	autofill.AutomaticSize = Enum.AutomaticSize.Y
	autofill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	autofill.BackgroundTransparency = 0.75
	autofill.BorderColor3 = Color3.fromRGB(0, 0, 0)
	autofill.BorderSizePixel = 0
	autofill.Position = UDim2.new(0.5, 0, 1, 10)
	autofill.Size = UDim2.new(1, 10, 0, 0)
	autofill.Visible = false

	local uICorner5 = Instance.new("UICorner")
	uICorner5.Name = "UICorner"
	uICorner5.Parent = autofill

	local scroller1 = Instance.new("ScrollingFrame")
	scroller1.Name = "Scroller"
	scroller1.Active = true
	scroller1.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	scroller1.BackgroundTransparency = 1
	scroller1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	scroller1.BorderSizePixel = 0
	scroller1.BottomImage = "rbxassetid://8082116996"
	scroller1.CanvasSize = UDim2.new()
	scroller1.MidImage = "rbxassetid://7488333553"
	scroller1.ScrollBarThickness = 5
	scroller1.Size = UDim2.fromScale(1, 1)
	scroller1.TopImage = "rbxassetid://8082122989"

	local listLayout1 = Instance.new("UIListLayout")
	listLayout1.Name = "ListLayout"
	listLayout1.Padding = UDim.new(0, 5)
	listLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout1.Parent = scroller1

	scroller1.Parent = autofill

	local uIPadding4 = Instance.new("UIPadding")
	uIPadding4.Name = "UIPadding"
	uIPadding4.PaddingBottom = UDim.new(0, 5)
	uIPadding4.PaddingLeft = UDim.new(0, 5)
	uIPadding4.PaddingRight = UDim.new(0, 5)
	uIPadding4.PaddingTop = UDim.new(0, 5)
	uIPadding4.Parent = autofill

	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.Name = "UISizeConstraint"
	uISizeConstraint.MaxSize = Vector2.new(math.huge, 200)
	uISizeConstraint.Parent = autofill

	autofill.Parent = main

	main.Parent = chat

	local basePadding = Instance.new("UIPadding")
	basePadding.Name = "BasePadding"
	basePadding.PaddingLeft = UDim.new(0, 5)
	basePadding.PaddingTop = UDim.new(0, 5)
	basePadding.Parent = chat

	local contextMenu = Instance.new("Frame")
	contextMenu.Name = "ContextMenu"
	contextMenu.AutomaticSize = Enum.AutomaticSize.Y
	contextMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	contextMenu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	contextMenu.BorderSizePixel = 0
	contextMenu.Position = UDim2.fromScale(0.959, 0.279)
	contextMenu.Size = UDim2.fromOffset(150, 0)
	contextMenu.Visible = false
	contextMenu.ZIndex = 3

	local uICorner6 = Instance.new("UICorner")
	uICorner6.Name = "UICorner"
	uICorner6.Parent = contextMenu

	local uIListLayout1 = Instance.new("UIListLayout")
	uIListLayout1.Name = "UIListLayout"
	uIListLayout1.Padding = UDim.new(0, 6)
	uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout1.Parent = contextMenu

	local reply = Instance.new("TextButton")
	reply.Name = "Reply"
	reply.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	reply.BackgroundTransparency = 1
	reply.BorderColor3 = Color3.fromRGB(0, 0, 0)
	reply.BorderSizePixel = 0
	reply.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	reply.LayoutOrder = 1
	reply.Size = UDim2.new(1, 0, 0, 20)
	reply.Text = "Reply"
	reply.TextColor3 = Color3.fromRGB(255, 255, 255)
	reply.TextSize = 14
	reply.TextXAlignment = Enum.TextXAlignment.Left
	reply.ZIndex = 3

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon.BackgroundTransparency = 1
	icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon.BorderSizePixel = 0
	icon.Image = "http://www.roblox.com/asset/?id=6035067844"
	icon.Position = UDim2.fromOffset(-25, 0)
	icon.Size = UDim2.fromScale(0, 1)
	icon.ZIndex = 3

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.AspectType = Enum.AspectType.ScaleWithParentSize
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint.Parent = icon

	icon.Parent = reply

	local uIPadding5 = Instance.new("UIPadding")
	uIPadding5.Name = "UIPadding"
	uIPadding5.PaddingLeft = UDim.new(0, 25)
	uIPadding5.Parent = reply

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0, -25, 1, 2)
	frame.Size = UDim2.new(1, 25, 0, 1)
	frame.ZIndex = 3
	frame.Parent = reply

	reply.Parent = contextMenu

	local uIPadding6 = Instance.new("UIPadding")
	uIPadding6.Name = "UIPadding"
	uIPadding6.PaddingBottom = UDim.new(0, 5)
	uIPadding6.PaddingLeft = UDim.new(0, 5)
	uIPadding6.PaddingRight = UDim.new(0, 5)
	uIPadding6.PaddingTop = UDim.new(0, 5)
	uIPadding6.Parent = contextMenu

	local save = Instance.new("TextButton")
	save.Name = "Save"
	save.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	save.BackgroundTransparency = 1
	save.BorderColor3 = Color3.fromRGB(0, 0, 0)
	save.BorderSizePixel = 0
	save.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	save.LayoutOrder = 1
	save.Size = UDim2.new(1, 0, 0, 20)
	save.Text = "Save"
	save.TextColor3 = Color3.fromRGB(255, 255, 255)
	save.TextSize = 14
	save.TextXAlignment = Enum.TextXAlignment.Left
	save.ZIndex = 3

	local icon1 = Instance.new("ImageLabel")
	icon1.Name = "Icon"
	icon1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon1.BackgroundTransparency = 1
	icon1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon1.BorderSizePixel = 0
	icon1.Image = "http://www.roblox.com/asset/?id=6031243319"
	icon1.Position = UDim2.fromOffset(-25, 0)
	icon1.Size = UDim2.fromScale(0, 1)
	icon1.ZIndex = 3

	local uIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint1.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint1.AspectType = Enum.AspectType.ScaleWithParentSize
	uIAspectRatioConstraint1.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint1.Parent = icon1

	icon1.Parent = save

	local uIPadding7 = Instance.new("UIPadding")
	uIPadding7.Name = "UIPadding"
	uIPadding7.PaddingLeft = UDim.new(0, 25)
	uIPadding7.Parent = save

	local frame1 = Instance.new("Frame")
	frame1.Name = "Frame"
	frame1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame1.BorderSizePixel = 0
	frame1.Position = UDim2.new(0, -25, 1, 2)
	frame1.Size = UDim2.new(1, 25, 0, 1)
	frame1.ZIndex = 3
	frame1.Parent = save

	save.Parent = contextMenu

	local delete = Instance.new("TextButton")
	delete.Name = "Delete"
	delete.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	delete.BackgroundTransparency = 1
	delete.BorderColor3 = Color3.fromRGB(0, 0, 0)
	delete.BorderSizePixel = 0
	delete.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	delete.LayoutOrder = 2
	delete.Size = UDim2.new(1, 0, 0, 20)
	delete.Text = "Delete"
	delete.TextColor3 = Color3.fromRGB(255, 204, 204)
	delete.TextSize = 14
	delete.TextXAlignment = Enum.TextXAlignment.Left
	delete.ZIndex = 3

	local icon2 = Instance.new("ImageLabel")
	icon2.Name = "Icon"
	icon2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon2.BackgroundTransparency = 1
	icon2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon2.BorderSizePixel = 0
	icon2.Image = "http://www.roblox.com/asset/?id=6022668885"
	icon2.ImageColor3 = Color3.fromRGB(255, 204, 204)
	icon2.Position = UDim2.fromOffset(-25, 0)
	icon2.Size = UDim2.fromScale(0, 1)
	icon2.ZIndex = 3

	local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint2.AspectType = Enum.AspectType.ScaleWithParentSize
	uIAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint2.Parent = icon2

	icon2.Parent = delete

	local uIPadding8 = Instance.new("UIPadding")
	uIPadding8.Name = "UIPadding"
	uIPadding8.PaddingLeft = UDim.new(0, 25)
	uIPadding8.Parent = delete

	delete.Parent = contextMenu

	local edit = Instance.new("TextButton")
	edit.Name = "Edit"
	edit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	edit.BackgroundTransparency = 1
	edit.BorderColor3 = Color3.fromRGB(0, 0, 0)
	edit.BorderSizePixel = 0
	edit.FontFace = Font.new(
		"rbxasset://fonts/families/GothamSSm.json",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	edit.LayoutOrder = 1
	edit.Size = UDim2.new(1, 0, 0, 20)
	edit.Text = "Edit"
	edit.TextColor3 = Color3.fromRGB(255, 255, 255)
	edit.TextSize = 14
	edit.TextXAlignment = Enum.TextXAlignment.Left
	edit.ZIndex = 3

	local icon3 = Instance.new("ImageLabel")
	icon3.Name = "Icon"
	icon3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	icon3.BackgroundTransparency = 1
	icon3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	icon3.BorderSizePixel = 0
	icon3.Image = "http://www.roblox.com/asset/?id=6034941708"
	icon3.Position = UDim2.fromOffset(-25, 0)
	icon3.Size = UDim2.fromScale(0, 1)
	icon3.ZIndex = 3

	local uIAspectRatioConstraint3 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint3.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint3.AspectType = Enum.AspectType.ScaleWithParentSize
	uIAspectRatioConstraint3.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint3.Parent = icon3

	icon3.Parent = edit

	local uIPadding9 = Instance.new("UIPadding")
	uIPadding9.Name = "UIPadding"
	uIPadding9.PaddingLeft = UDim.new(0, 25)
	uIPadding9.Parent = edit

	local frame2 = Instance.new("Frame")
	frame2.Name = "Frame"
	frame2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.new(0, -25, 1, 2)
	frame2.Size = UDim2.new(1, 25, 0, 1)
	frame2.ZIndex = 3
	frame2.Parent = edit

	edit.Parent = contextMenu

	local reactions = Instance.new("Frame")
	reactions.Name = "Reactions"
	reactions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	reactions.BackgroundTransparency = 1
	reactions.BorderColor3 = Color3.fromRGB(0, 0, 0)
	reactions.BorderSizePixel = 0
	reactions.Size = UDim2.new(1, 0, 0, 35)
	reactions.ZIndex = 3

	local frame3 = Instance.new("Frame")
	frame3.Name = "Frame"
	frame3.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	frame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame3.BorderSizePixel = 0
	frame3.Position = UDim2.new(0, 0, 1, 2)
	frame3.Size = UDim2.new(1, 0, 0, 1)
	frame3.ZIndex = 3
	frame3.Parent = reactions

	local options = Instance.new("Frame")
	options.Name = "Options"
	options.AnchorPoint = Vector2.new(0.5, 0.5)
	options.AutomaticSize = Enum.AutomaticSize.X
	options.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	options.BorderColor3 = Color3.fromRGB(0, 0, 0)
	options.BorderSizePixel = 0
	options.Position = UDim2.fromScale(0.5, 0.5)
	options.Size = UDim2.new(1, 0, 0, 30)
	options.ZIndex = 3

	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.Name = "UIListLayout"
	uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout2.Padding = UDim.new(0, 5)
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout2.Parent = options

	local textButton1 = Instance.new("TextButton")
	textButton1.Name = "TextButton"
	textButton1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textButton1.BackgroundTransparency = 1
	textButton1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textButton1.BorderSizePixel = 0
	textButton1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton1.Size = UDim2.fromOffset(20, 20)
	textButton1.Text = "😂"
	textButton1.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton1.TextScaled = true
	textButton1.TextSize = 14
	textButton1.TextWrapped = true
	textButton1.ZIndex = 3
	textButton1.Parent = options

	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "TextButton"
	textButton2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textButton2.BackgroundTransparency = 1
	textButton2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textButton2.BorderSizePixel = 0
	textButton2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton2.Size = UDim2.fromOffset(20, 20)
	textButton2.Text = "😢"
	textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton2.TextScaled = true
	textButton2.TextSize = 14
	textButton2.TextWrapped = true
	textButton2.ZIndex = 3
	textButton2.Parent = options

	local textButton3 = Instance.new("TextButton")
	textButton3.Name = "TextButton"
	textButton3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textButton3.BackgroundTransparency = 1
	textButton3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textButton3.BorderSizePixel = 0
	textButton3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton3.Size = UDim2.fromOffset(20, 20)
	textButton3.Text = "🤔"
	textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton3.TextScaled = true
	textButton3.TextSize = 14
	textButton3.TextWrapped = true
	textButton3.ZIndex = 3
	textButton3.Parent = options

	local textButton4 = Instance.new("TextButton")
	textButton4.Name = "TextButton"
	textButton4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textButton4.BackgroundTransparency = 1
	textButton4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textButton4.BorderSizePixel = 0
	textButton4.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	textButton4.Size = UDim2.fromOffset(20, 20)
	textButton4.Text = "❤️"
	textButton4.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton4.TextScaled = true
	textButton4.TextSize = 14
	textButton4.TextWrapped = true
	textButton4.ZIndex = 3
	textButton4.Parent = options

	local add = Instance.new("ImageButton")
	add.Name = "Add"
	add.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	add.BackgroundTransparency = 1
	add.BorderColor3 = Color3.fromRGB(0, 0, 0)
	add.BorderSizePixel = 0
	add.Image = "http://www.roblox.com/asset/?id=6035047377"
	add.LayoutOrder = 1
	add.Size = UDim2.fromOffset(20, 20)
	add.ZIndex = 3
	add.Parent = options

	local uICorner7 = Instance.new("UICorner")
	uICorner7.Name = "UICorner"
	uICorner7.CornerRadius = UDim.new(1, 0)
	uICorner7.Parent = options

	local uIPadding10 = Instance.new("UIPadding")
	uIPadding10.Name = "UIPadding"
	uIPadding10.PaddingBottom = UDim.new(0, 10)
	uIPadding10.PaddingLeft = UDim.new(0, 10)
	uIPadding10.PaddingRight = UDim.new(0, 10)
	uIPadding10.PaddingTop = UDim.new(0, 10)
	uIPadding10.Parent = options
	
	local additionalContext = Instance.new("Frame")
	additionalContext.Name = "Context"
	additionalContext.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	additionalContext.BackgroundTransparency = 1
	additionalContext.BorderColor3 = Color3.fromRGB(0, 0, 0)
	additionalContext.BorderSizePixel = 0
	additionalContext.Size = UDim2.fromOffset(400, 25)
	
	local additionalContextLabel = Instance.new("TextLabel")
	additionalContextLabel.Name = "ContextLabel"
	additionalContextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	additionalContextLabel.BackgroundTransparency = 1
	additionalContextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	additionalContextLabel.BorderSizePixel = 0
	additionalContextLabel.Size = UDim2.fromOffset(390, 25)
	additionalContextLabel.TextColor = BrickColor.White()
	additionalContextLabel.TextXAlignment = Enum.TextXAlignment.Left
	additionalContextLabel.Text = ""
	additionalContextLabel.Parent = additionalContext
	
	local uICorner8 = Instance.new("UICorner")
	uICorner8.Name = "UICorner"
	uICorner8.CornerRadius = UDim.new(1, 0)
	uICorner8.Parent = additionalContextLabel

	additionalContext.Parent = main

	options.Parent = reactions

	reactions.Parent = contextMenu

	contextMenu.Parent = chat
	

	

	return chat
end