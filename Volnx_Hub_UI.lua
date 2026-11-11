--[[
    VOLNX HUB UI
    Roblox LocalScript
    Place in StarterPlayer > StarterPlayerScripts.

    UI-only foundation: Aim, Combat, Combos, Attack tabs.
    Feature logic can be connected later through the toggle/button callbacks.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("VolnxHubUI")
if old then old:Destroy() end

local COLORS = {
    bg = Color3.fromRGB(12, 14, 19),
    panel = Color3.fromRGB(19, 22, 29),
    panel2 = Color3.fromRGB(26, 30, 39),
    text = Color3.fromRGB(244, 247, 255),
    muted = Color3.fromRGB(139, 148, 166),
    accent = Color3.fromRGB(126, 107, 255),
    accent2 = Color3.fromRGB(75, 196, 255),
    stroke = Color3.fromRGB(190, 205, 255),
    green = Color3.fromRGB(93, 224, 166),
    red = Color3.fromRGB(255, 104, 120),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function stroke(parent, color, transparency, thickness)
    return make("UIStroke", {
        Color = color or COLORS.stroke,
        Transparency = transparency or 0.72,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function tween(obj, duration, style, direction, props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local gui = make("ScreenGui", {
    Name = "VolnxHubUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- Soft ambient glow behind the glass panel.
local glow = make("Frame", {
    Name = "AmbientGlow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.48),
    Size = UDim2.fromOffset(510, 390),
    BackgroundColor3 = COLORS.accent,
    BackgroundTransparency = 0.91,
    BorderSizePixel = 0,
    ZIndex = 0,
}, gui)
corner(glow, 36)

local shadow = make("ImageLabel", {
    Name = "Shadow",
    BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993",
    ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.28,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.48),
    Size = UDim2.fromOffset(500, 380),
    ZIndex = 0,
}, gui)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.48),
    Size = UDim2.fromOffset(460, 340),
    BackgroundColor3 = COLORS.bg,
    BackgroundTransparency = 0.13,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
}, gui)
corner(main, 25)
stroke(main, COLORS.stroke, 0.58, 1.15)

local glassGradient = make("UIGradient", {
    Rotation = 135,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 39, 55)),
        ColorSequenceKeypoint.new(0.48, COLORS.bg),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 27, 40)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.18),
        NumberSequenceKeypoint.new(1, 0.02),
    }),
}, main)

local top = make("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1,
    ZIndex = 4,
}, main)

local island = make("Frame", {
    Name = "IslandAccent",
    Position = UDim2.fromOffset(15, 12),
    Size = UDim2.fromOffset(34, 34),
    BackgroundColor3 = Color3.fromRGB(8, 10, 15),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 5,
}, top)
corner(island, 17)
stroke(island, COLORS.stroke, 0.72, 1)

local islandDot = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = COLORS.accent2,
    BorderSizePixel = 0,
    ZIndex = 6,
}, island)
corner(islandDot, 8)

local title = make("TextLabel", {
    Position = UDim2.fromOffset(59, 8),
    Size = UDim2.new(1, -155, 0, 25),
    BackgroundTransparency = 1,
    Text = "VOLNX HUB",
    TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
}, top)

local subtitle = make("TextLabel", {
    Position = UDim2.fromOffset(60, 31),
    Size = UDim2.new(1, -160, 0, 16),
    BackgroundTransparency = 1,
    Text = "GLASS INTERFACE  •  V1",
    TextColor3 = COLORS.muted,
    Font = Enum.Font.GothamMedium,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
}, top)

local function makeTopButton(text, x, color)
    local b = make("TextButton", {
        Position = UDim2.new(1, x, 0, 13),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = COLORS.panel2,
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = color or COLORS.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 17,
        AutoButtonColor = false,
        ZIndex = 6,
    }, top)
    corner(b, 10)
    stroke(b, COLORS.stroke, 0.82, 1)
    b.MouseEnter:Connect(function()
        tween(b, 0.16, nil, nil, {BackgroundTransparency = 0, BackgroundColor3 = COLORS.panel2})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.16, nil, nil, {BackgroundTransparency = 0.18})
    end)
    return b
end

local minimize = makeTopButton("−", -75)
local close = makeTopButton("×", -39, COLORS.red)

local divider = make("Frame", {
    Position = UDim2.fromOffset(16, 57),
    Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = COLORS.stroke,
    BackgroundTransparency = 0.86,
    BorderSizePixel = 0,
    ZIndex = 4,
}, main)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(14, 72),
    Size = UDim2.fromOffset(116, 252),
    BackgroundColor3 = COLORS.panel,
    BackgroundTransparency = 0.28,
    BorderSizePixel = 0,
    ZIndex = 4,
}, main)
corner(sidebar, 17)
stroke(sidebar, COLORS.stroke, 0.88, 1)

make("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, sidebar)

make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = make("Frame", {
    Position = UDim2.fromOffset(142, 72),
    Size = UDim2.new(1, -156, 1, -88),
    BackgroundTransparency = 1,
    ZIndex = 4,
}, main)

local pageTitle = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 26),
    BackgroundTransparency = 1,
    Text = "AIM",
    TextColor3 = COLORS.text,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
}, content)

local pageHint = make("TextLabel", {
    Position = UDim2.fromOffset(0, 25),
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "Configure your preferences",
    TextColor3 = COLORS.muted,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
}, content)

local pageBody = make("Frame", {
    Position = UDim2.fromOffset(0, 54),
    Size = UDim2.new(1, 0, 1, -54),
    BackgroundTransparency = 1,
    ZIndex = 5,
}, content)

local tabs = {"Aim", "Combat", "Combos", "Attack"}
local tabButtons = {}
local selectedTab = "Aim"

local function clearPage()
    for _, child in ipairs(pageBody:GetChildren()) do
        child:Destroy()
    end
end

local function makeInfoCard(titleText, descText, order)
    local card = make("Frame", {
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = COLORS.panel2,
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, pageBody)
    corner(card, 14)
    stroke(card, COLORS.stroke, 0.88, 1)

    make("TextLabel", {
        Position = UDim2.fromOffset(13, 10),
        Size = UDim2.new(1, -25, 0, 19),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = COLORS.text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, card)

    make("TextLabel", {
        Position = UDim2.fromOffset(13, 32),
        Size = UDim2.new(1, -25, 0, 20),
        BackgroundTransparency = 1,
        Text = descText,
        TextColor3 = COLORS.muted,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    }, card)
end

local function renderPage(tabName)
    selectedTab = tabName
    pageTitle.Text = string.upper(tabName)
    pageHint.Text = tabName == "Combos" and "Combo presets and sequences"
        or tabName == "Attack" and "Attack options and settings"
        or tabName == "Combat" and "Combat preferences"
        or "Aim preferences"

    clearPage()
    make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, pageBody)

    makeInfoCard(tabName .. " Settings", "UI section ready — feature logic can be added here.", 1)
    makeInfoCard("Status", "No gameplay action is connected yet.", 2)

    for name, button in pairs(tabButtons) do
        local active = name == tabName
        tween(button, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
            BackgroundColor3 = active and COLORS.accent or COLORS.panel2,
            BackgroundTransparency = active and 0.08 or 0.48,
            TextColor3 = active and Color3.new(1, 1, 1) or COLORS.muted,
        })
    end
end

for i, tabName in ipairs(tabs) do
    local button = make("TextButton", {
        Name = tabName .. "Tab",
        LayoutOrder = i,
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundColor3 = COLORS.panel2,
        BackgroundTransparency = 0.48,
        BorderSizePixel = 0,
        Text = tabName,
        TextColor3 = COLORS.muted,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        AutoButtonColor = false,
        ZIndex = 5,
    }, sidebar)
    corner(button, 12)
    stroke(button, COLORS.stroke, 0.91, 1)
    tabButtons[tabName] = button

    button.MouseButton1Click:Connect(function()
        renderPage(tabName)
    end)
end

renderPage("Aim")

-- Dragging from the header.
local dragging = false
local dragStart, startPosition
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
        shadow.Position = main.Position
        glow.Position = main.Position
    end
end)

-- Dynamic-Island-inspired collapse/expand.
local expandedSize = UDim2.fromOffset(460, 340)
local collapsedSize = UDim2.fromOffset(170, 48)
local isCollapsed = false
local isClosed = false
local transitionBusy = false

local function collapse()
    if transitionBusy or isClosed then return end
    transitionBusy = true
    isCollapsed = true

    tween(main, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.In, {
        Size = collapsedSize,
        BackgroundTransparency = 0.04,
    })
    tween(shadow, 0.35, nil, nil, {Size = UDim2.fromOffset(205, 75)})
    tween(glow, 0.35, nil, nil, {Size = UDim2.fromOffset(220, 90), BackgroundTransparency = 0.94})

    task.delay(0.43, function()
        if not isClosed then
            for _, child in ipairs(main:GetChildren()) do
                if child ~= top and child ~= main:FindFirstChildOfClass("UICorner")
                    and child ~= main:FindFirstChildOfClass("UIStroke")
                    and child ~= glassGradient then
                    child.Visible = false
                end
            end
            title.Text = "VOLNX"
            subtitle.Text = "TAP TO EXPAND"
            island.Position = UDim2.fromOffset(10, 7)
            island.Size = UDim2.fromOffset(34, 34)
            minimize.Text = "+"
            transitionBusy = false
        end
    end)
end

local function expand()
    if transitionBusy or isClosed then return end
    transitionBusy = true
    isCollapsed = false

    for _, child in ipairs(main:GetChildren()) do
        if child ~= top and child ~= main:FindFirstChildOfClass("UICorner")
            and child ~= main:FindFirstChildOfClass("UIStroke")
            and child ~= glassGradient then
            child.Visible = true
        end
    end

    title.Text = "VOLNX HUB"
    subtitle.Text = "GLASS INTERFACE  •  V1"
    minimize.Text = "−"
    island.Position = UDim2.fromOffset(15, 12)
    tween(main, 0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        Size = expandedSize,
        BackgroundTransparency = 0.13,
    })
    tween(shadow, 0.42, nil, nil, {Size = UDim2.fromOffset(500, 380)})
    tween(glow, 0.42, nil, nil, {Size = UDim2.fromOffset(510, 390), BackgroundTransparency = 0.91})
    task.delay(0.5, function() transitionBusy = false end)
end

minimize.MouseButton1Click:Connect(function()
    if isCollapsed then expand() else collapse() end
end)

-- Tap the collapsed capsule to restore the full panel.
main.InputBegan:Connect(function(input)
    if isCollapsed and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        expand()
    end
end)

close.MouseButton1Click:Connect(function()
    if transitionBusy or isClosed then return end
    isClosed = true
    transitionBusy = true
    tween(main, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In, {
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
    })
    tween(shadow, 0.22, nil, nil, {ImageTransparency = 1, Size = UDim2.fromOffset(0, 0)})
    tween(glow, 0.22, nil, nil, {BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0)})
    task.delay(0.28, function()
        gui:Destroy()
    end)
end)

-- Subtle animated accent shimmer.
local rotation = 0
local shimmerConnection
shimmerConnection = RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then
        shimmerConnection:Disconnect()
        return
    end
    rotation = (rotation + dt * 7) % 360
    glassGradient.Rotation = 135 + math.sin(math.rad(rotation)) * 5
end)
