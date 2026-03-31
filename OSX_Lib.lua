local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme / Constants (Stealth Monochrome Redesign)
OSX_Lib.Theme = {
    MainBG = Color3.fromRGB(2, 2, 2), -- Deeper Black
    MainTransparency = 0.02,
    CardBG = Color3.fromRGB(14, 14, 14), -- Darker Cards
    CardTransparency = 0.2,
    Accent = Color3.fromRGB(255, 255, 255), -- Pure White Accent
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 160, 160), -- More readable dim
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.92,
    SideItemActiveBG = Color3.fromRGB(30, 30, 30), -- Subtle active highlight
    SideItemActiveTransparency = 0.5,
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    CornerRadius = 12,
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.4
}

-- Icon Mapping & Downloader (Lucide & URLs)
local IconMap = {
    ["home"] = "https://img.icons8.com/ios-filled/50/ffffff/home.png",
    ["user"] = "https://img.icons8.com/ios-filled/50/ffffff/user.png",
    ["eye"] = "https://img.icons8.com/ios-filled/50/ffffff/visible.png",
    ["settings"] = "https://img.icons8.com/ios-filled/50/ffffff/settings.png",
    ["info"] = "https://img.icons8.com/ios-filled/50/ffffff/info.png",
    ["database"] = "https://img.icons8.com/ios-filled/50/ffffff/database.png",
    ["shield"] = "https://img.icons8.com/ios-filled/50/ffffff/shield.png",
    ["lock"] = "https://img.icons8.com/ios-filled/50/ffffff/lock.png"
}

local function GetIcon(Name)
    if not Name or Name == "" then return "" end
    Name = Name:lower()
    
    -- 1. Check Icon Mapping
    local Target = IconMap[Name] or Name
    
    -- 2. If already an asset ID, return it
    if string.find(Target, "rbxassetid://") or tonumber(Target) then
        return string.find(Target, "rbxassetid://") and Target or "rbxassetid://" .. Target
    end

    -- 3. If it's a URL, try Download & Cache
    if string.find(Target, "http") then
        local customasset = getcustomasset or get_custom_asset -- Better executor support
        local success, result = pcall(function()
            if not (writefile and customasset and isfile) then 
                error("Executor does not support file/asset functions")
            end
            
            local SafeName = Name:gsub("%W", "")
            local FileName = "OSX_v4_" .. SafeName .. ".png"
            if not isfile(FileName) then
                local CleanTarget = Target:split("?")[1] -- Remove query params if any
                local data = game:HttpGet(CleanTarget)
                if not data or data == "" then error("HttpGet returned empty data") end
                writefile(FileName, data)
            end
            return customasset(FileName)
        end)
        
        if success and result then
            return result
        end
        warn("OSX Lib: Failed to load icon '" .. Name .. "'. Reason: " .. tostring(result))
    end

    -- 4. Final Fallback to reliable ids
    local Fallbacks = {
        ["info"] = "rbxassetid://10723415903",
        ["home"] = "rbxassetid://10723343321",
        ["user"] = "rbxassetid://11293988182",
        ["eye"] = "rbxassetid://11295291410",
        ["settings"] = "rbxassetid://11293971586",
        ["database"] = "rbxassetid://11294101962",
        -- Universal & Farming Icons (v7 Expansion)
        ["target"] = "rbxassetid://11295175655",         -- Crosshair / Aimbot
        ["crosshair"] = "rbxassetid://11295175655",      -- Alias for target
        ["shield"] = "rbxassetid://11294026362",         -- Checks / Anti-Ban
        ["sword"] = "rbxassetid://11293986790",          -- Auto Farm / Attack
        ["shopping-cart"] = "rbxassetid://10723415494",  -- Store / Auto Buy
        ["map"] = "rbxassetid://11293980145",            -- Waypoints / Teleports
        ["mouse"] = "rbxassetid://11293981880",          -- Auto Clicker
        ["list"] = "rbxassetid://11293977508",           -- Logs / Filters
        ["monitor"] = "rbxassetid://11293977821"         -- FPS / System
    }

    return Fallbacks[Name] or ""
end

-- Utility Functions
local function MakeDraggable(Frame, Handle)
    Handle = Handle or Frame
    local Dragging = false
    local DragStart = nil
    local StartPos = nil

    Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            Frame.Position = UDim2.new(
                StartPos.X.Scale, 
                StartPos.X.Offset + Delta.X, 
                StartPos.Y.Scale, 
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

-- Global Notification System
local NotifyContainer = nil
function OSX_Lib:Notify(Config)
    Config = Config or {}
    local TitleText = Config.Title or "OSX HUB"
    local ContentText = Config.Content or "Notification"
    local Duration = Config.Duration or 3
    
    if not NotifyContainer then
        NotifyContainer = Instance.new("ScreenGui")
        NotifyContainer.Name = "OSX_Notifications"
        NotifyContainer.Parent = game:GetService("CoreGui")
        
        local Layout = Instance.new("UIListLayout")
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = NotifyContainer
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 20)
        Padding.PaddingRight = UDim.new(0, 20)
        Padding.Parent = NotifyContainer
    end
    
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 280, 0, 70)
    Notif.BackgroundColor3 = OSX_Lib.Theme.MainBG
    Notif.BackgroundTransparency = 0.1
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.Parent = NotifyContainer
    
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = OSX_Lib.Theme.Accent
    Stroke.Transparency = 0.8
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = OSX_Lib.Theme.TextMain
    Title.TextSize = 14
    Title.Font = OSX_Lib.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notif
    
    local Content = Instance.new("TextLabel")
    Content.Size = UDim2.new(1, -20, 0, 20)
    Content.Position = UDim2.new(0, 15, 0, 35)
    Content.BackgroundTransparency = 1
    Content.Text = ContentText
    Content.TextColor3 = OSX_Lib.Theme.TextDim
    Content.TextSize = 12
    Content.Font = OSX_Lib.Theme.Font
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.Parent = Notif
    
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.BackgroundColor3 = OSX_Lib.Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Parent = Notif
    
    Notif.Position = UDim2.new(1, 300, 0, 0)
    TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0,0,0,0)}):Play()
    TweenService:Create(Bar, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()
    
    task.delay(Duration, function()
        TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 300, 0, 0)}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

function OSX_Lib:CreateWindow(Config)
    Config = Config or {}
    local TitleText = Config.Title or "OSX HUB | SITE VERSION"
    local SubtitleText = Config.Subtitle or "Made by: LilYouDev1997 | Discord: discord.gg/osxhub"
    local MainLogoId = GetIcon(Config.WindowLogo or "info")
    local FloatLogoId = GetIcon(Config.FloatingLogo or MainLogoId)
    local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightControl
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OSX_Lib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    -- Main Container (Pronounced rounded corners)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Position = UDim2.new(0.5, -350, 0.5, -250)
    Main.Size = UDim2.new(0, 700, 0, 500)
    Main.BackgroundColor3 = OSX_Lib.Theme.MainBG
    Main.BackgroundTransparency = OSX_Lib.Theme.MainTransparency
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, OSX_Lib.Theme.CornerRadius)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = OSX_Lib.Theme.BorderColor
    MainStroke.Transparency = OSX_Lib.Theme.BorderTransparency
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    -- Top Header (Wider style)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Main -- MUST BE PARENTED FIRST
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundTransparency = 1

    -- Logo Box (OSXH)
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "LogoContainer"
    LogoContainer.Position = UDim2.new(0, 25, 0, 15)
    LogoContainer.Size = UDim2.new(0, 55, 0, 45)
    LogoContainer.BackgroundTransparency = 1 -- Transparent Background
    LogoContainer.Parent = Header

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 10)
    LogoCorner.Parent = LogoContainer

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Size = UDim2.new(1, 0, 1, 0) -- Full Size
    LogoImage.Position = UDim2.new(0, 0, 0, 0)
    LogoImage.BackgroundTransparency = 1
    LogoImage.Image = MainLogoId
    LogoImage.ScaleType = Enum.ScaleType.Fit
    LogoImage.Parent = LogoContainer

    -- Detailed Title/Subtitle Layout
    local TitleInfo = Instance.new("Frame")
    TitleInfo.Name = "TitleInfo"
    TitleInfo.Position = UDim2.new(0, 95, 0, 15)
    TitleInfo.Size = UDim2.new(1, -150, 0, 45)
    TitleInfo.BackgroundTransparency = 1
    TitleInfo.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = OSX_Lib.Theme.TextMain
    Title.TextSize = 17
    Title.Font = OSX_Lib.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleInfo

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Position = UDim2.new(0, 0, 0.5, 5)
    Subtitle.Size = UDim2.new(1, 0, 0.5, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = SubtitleText
    Subtitle.TextColor3 = OSX_Lib.Theme.TextDim
    Subtitle.TextSize = 11
    Subtitle.Font = OSX_Lib.Theme.Font
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleInfo

    -- Header Buttons Container
    local BtnContainer = Instance.new("Frame")
    BtnContainer.Name = "BtnContainer"
    BtnContainer.Position = UDim2.new(1, -100, 0, 25)
    BtnContainer.Size = UDim2.new(0, 80, 0, 30)
    BtnContainer.BackgroundTransparency = 1
    BtnContainer.Parent = Header

    local BtnLayout = Instance.new("UIListLayout")
    BtnLayout.FillDirection = Enum.FillDirection.Horizontal
    BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BtnLayout.Padding = UDim.new(0, 10)
    BtnLayout.Parent = BtnContainer

    -- Close (X) Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = OSX_Lib.Theme.TextDim
    CloseBtn.TextSize = 18
    CloseBtn.Font = OSX_Lib.Theme.FontBold
    CloseBtn.LayoutOrder = 2
    CloseBtn.Parent = BtnContainer

    -- Minimize (-) Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = OSX_Lib.Theme.TextDim
    MinimizeBtn.TextSize = 24
    MinimizeBtn.Font = OSX_Lib.Theme.FontBold
    MinimizeBtn.LayoutOrder = 1
    MinimizeBtn.Parent = BtnContainer

    local function ApplyBtnHover(btn, hoverCol)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = hoverCol}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = OSX_Lib.Theme.TextDim}):Play()
        end)
    end

    ApplyBtnHover(CloseBtn, Color3.fromRGB(227, 52, 52))
    ApplyBtnHover(MinimizeBtn, OSX_Lib.Theme.Accent)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Separation Line
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(0, 0, 1, 0)
    Separator.Size = UDim2.new(1, 0, 0, 1)
    Separator.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    Separator.BackgroundTransparency = 0.95
    Separator.BorderSizePixel = 0
    Separator.Parent = Header

    -- Body
    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Position = UDim2.new(0, 0, 0, 76)
    Body.Size = UDim2.new(1, 0, 1, -76)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    -- Sidebar (Icon + Title + Sub-description)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    Sidebar.BackgroundTransparency = 0.985
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.Name = "Border"
    SidebarRightBorder.Position = UDim2.new(1, 0, 0, 0)
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightBorder.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    SidebarRightBorder.BackgroundTransparency = 0.95
    SidebarRightBorder.BorderSizePixel = 0
    SidebarRightBorder.Parent = Sidebar

    local SidebarList = Instance.new("ScrollingFrame")
    SidebarList.Name = "SidebarList"
    SidebarList.Size = UDim2.new(1, 0, 1, 0)
    SidebarList.BackgroundTransparency = 1
    SidebarList.BorderSizePixel = 0
    SidebarList.ScrollBarThickness = 0
    SidebarList.CanvasSize = UDim2.new(0, 0, 0, 0)
    SidebarList.Parent = Sidebar

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 8)
    SidebarLayout.Parent = SidebarList

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 15)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingRight = UDim.new(0, 10)
    SidebarPadding.Parent = SidebarList

    -- Container (Main Content)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 175, 0, 0)
    Container.Size = UDim2.new(1, -175, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Body

    -- Toggle Logic
    local UI_Visible = true
    
    -- Floating Icon GUI
    local FloatingGui = Instance.new("ScreenGui")
    FloatingGui.Name = "OSX_Floating"
    FloatingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FloatingGui.Enabled = false
    FloatingGui.Parent = game:GetService("CoreGui")

    local FloatingFrame = Instance.new("Frame")
    FloatingFrame.Size = UDim2.new(0, 60, 0, 60)
    FloatingFrame.Position = UDim2.new(0, 50, 0, 200)
    FloatingFrame.BackgroundTransparency = 1 -- Fully Transparent
    FloatingFrame.BorderSizePixel = 0
    FloatingFrame.Parent = FloatingGui

    local FloatingCorner = Instance.new("UICorner")
    FloatingCorner.CornerRadius = UDim.new(1, 0)
    FloatingCorner.Parent = FloatingFrame

    local FloatingLogo = Instance.new("ImageLabel")
    FloatingLogo.Size = UDim2.new(1, 0, 1, 0) -- Full Size
    FloatingLogo.Position = UDim2.new(0, 0, 0, 0)
    FloatingLogo.BackgroundTransparency = 1
    FloatingLogo.Image = FloatLogoId
    FloatingLogo.ScaleType = Enum.ScaleType.Fit
    FloatingLogo.Parent = FloatingFrame

    -- UI Visibility Control
    local function SetUIVisible(state)
        UI_Visible = state
        Main.Visible = state
        FloatingGui.Enabled = not state
    end

    MinimizeBtn.MouseButton1Click:Connect(function()
        SetUIVisible(false)
    end)

    -- Mobile Dragging + Clicking Logic (Directly on frame)
    local DragStartPos = Vector2.new()
    local Clicking = false
    
    FloatingFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            DragStartPos = Vector2.new(Input.Position.X, Input.Position.Y)
            Clicking = true
        end
    end)
    
    FloatingFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            local EndPos = Vector2.new(Input.Position.X, Input.Position.Y)
            local Dist = (EndPos - DragStartPos).Magnitude
            if Clicking and Dist < 10 then -- If moved less than 10px, it's a click
                SetUIVisible(true)
            end
            Clicking = false
        end
    end)
    
    -- Final Connections
    SetUIVisible(true)
    
    MakeDraggable(Main, Header)
    MakeDraggable(FloatingFrame, FloatingFrame)

    UserInputService.InputBegan:Connect(function(Input)
        if Input.KeyCode == ToggleKey or Input.KeyCode == Enum.KeyCode.RightControl then
            SetUIVisible(not UI_Visible)
        end
    end)

    local CurrentTab = nil

    local function AddTab(TabConfig)
        TabConfig = TabConfig or {}
        local TabTitle = TabConfig.Title or "Tab"
        local TabSub = TabConfig.SubDescription or "Information"
        local TabIconId = GetIcon(TabConfig.Icon or "info")

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabTitle .. "_Btn"
        TabButton.Size = UDim2.new(1, 0, 0, 60)
        TabButton.BackgroundTransparency = 1
        TabButton.BackgroundColor3 = OSX_Lib.Theme.SideItemActiveBG
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = SidebarList

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 12)
        TabButtonCorner.Parent = TabButton

        -- Thick Rounded Active Border (Left)
        local ActiveIndicator = Instance.new("Frame")
        ActiveIndicator.Name = "ActiveIndicator"
        ActiveIndicator.Size = UDim2.new(0, 4, 0.4, 0)
        ActiveIndicator.Position = UDim2.new(0, -6, 0.3, 0)
        ActiveIndicator.BackgroundColor3 = OSX_Lib.Theme.Accent
        ActiveIndicator.BackgroundTransparency = 1
        ActiveIndicator.BorderSizePixel = 0
        ActiveIndicator.Parent = TabButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ActiveIndicator

        -- Icon
        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Position = UDim2.new(0, 15, 0.5, -12)
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.BackgroundTransparency = 1
        Icon.Image = TabIconId
        Icon.ImageColor3 = OSX_Lib.Theme.TextMain
        Icon.ImageTransparency = 0.6
        Icon.Parent = TabButton

        -- Text Labels
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -55, 0.4, 0)
        TabLabel.Position = UDim2.new(0, 50, 0.25, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabTitle
        TabLabel.TextColor3 = OSX_Lib.Theme.TextMain
        TabLabel.TextSize = 14
        TabLabel.Font = OSX_Lib.Theme.FontBold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.TextTransparency = 0.6
        TabLabel.Parent = TabButton

        local TabSubLabel = Instance.new("TextLabel")
        TabSubLabel.Size = UDim2.new(1, -55, 0.3, 0)
        TabSubLabel.Position = UDim2.new(0, 50, 0.65, 0)
        TabSubLabel.BackgroundTransparency = 1
        TabSubLabel.Text = TabSub
        TabSubLabel.TextColor3 = OSX_Lib.Theme.TextDim
        TabSubLabel.TextSize = 11
        TabSubLabel.Font = OSX_Lib.Theme.Font
        TabSubLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabSubLabel.TextTransparency = 0.6
        TabSubLabel.Parent = TabButton

        -- Tab Content
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabTitle .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = OSX_Lib.Theme.Accent
        TabPage.ScrollBarImageTransparency = 0.6
        -- Enable Automatic Scrolling
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = Container

        local TabPageLayout = Instance.new("UIListLayout")
        TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabPageLayout.Padding = UDim.new(0, 15) -- Increased spacing between panels
        TabPageLayout.Parent = TabPage

        local TabPagePadding = Instance.new("UIPadding")
        TabPagePadding.PaddingTop = UDim.new(0, 25)
        TabPagePadding.PaddingLeft = UDim.new(0, 30)
        TabPagePadding.PaddingRight = UDim.new(0, 30)
        TabPagePadding.Parent = TabPage

        -- Selection Logic
        local function Select()
            if CurrentTab then
                CurrentTab.Page.Visible = false
                TweenService:Create(CurrentTab.Btn.ActiveIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, 4, 0.4, 0)}):Play()
                TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(CurrentTab.Btn.Icon, TweenInfo.new(0.3), {ImageTransparency = 0.6}):Play()
                TweenService:Create(CurrentTab.Label, TweenInfo.new(0.3), {TextTransparency = 0.6}):Play()
                TweenService:Create(CurrentTab.SubLabel, TweenInfo.new(0.3), {TextTransparency = 0.6}):Play()
            end

            CurrentTab = {Btn = TabButton, Page = TabPage, Label = TabLabel, SubLabel = TabSubLabel}
            TabPage.Visible = true
            TweenService:Create(TabButton.ActiveIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 0, Size = UDim2.new(0, 4, 0.7, 0)}):Play()
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = OSX_Lib.Theme.SideItemActiveTransparency}):Play()
            TweenService:Create(TabButton.Icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            TweenService:Create(TabSubLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end

        TabButton.MouseButton1Click:Connect(Select)

        -- Element Generator Table
        local Elements = {}

        -- Internal function to wrap element creation
        local function RegisterElement(func)
            return function(self, ...)
                return func(...)
            end
        end

        -- AddPanel: Rounded card container
        function Elements:AddPanel(PanelTitle)
            local PanelFrame = Instance.new("Frame")
            PanelFrame.Size = UDim2.new(1, 0, 0, 40)
            PanelFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            PanelFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            PanelFrame.Parent = TabPage

            local PanelCorner = Instance.new("UICorner")
            PanelCorner.CornerRadius = UDim.new(0, 10)
            PanelCorner.Parent = PanelFrame

            local PanelStroke = Instance.new("UIStroke")
            PanelStroke.Color = OSX_Lib.Theme.BorderColor
            PanelStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            PanelStroke.Thickness = 1
            PanelStroke.Parent = PanelFrame

            local PanelHeader = Instance.new("TextLabel")
            PanelHeader.Size = UDim2.new(1, 0, 0, 40)
            PanelHeader.Position = UDim2.new(0, 20, 0, 5)
            PanelHeader.BackgroundTransparency = 1
            PanelHeader.Text = PanelTitle or ""
            PanelHeader.TextColor3 = OSX_Lib.Theme.TextMain
            PanelHeader.TextSize = 14
            PanelHeader.Font = OSX_Lib.Theme.FontBold
            PanelHeader.TextXAlignment = Enum.TextXAlignment.Left
            PanelHeader.Parent = PanelFrame

            local PanelList = Instance.new("Frame")
            PanelList.Name = "PanelList"
            PanelList.Position = UDim2.new(0, 0, 0, 50)
            PanelList.Size = UDim2.new(1, 0, 0, 0)
            PanelList.BackgroundTransparency = 1
            PanelList.Parent = PanelFrame

            local PanelLayout = Instance.new("UIListLayout")
            PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
            PanelLayout.Padding = UDim.new(0, 8)
            PanelLayout.Parent = PanelList

            local PanelPadding = Instance.new("UIPadding")
            PanelPadding.PaddingLeft = UDim.new(0, 20)
            PanelPadding.PaddingRight = UDim.new(0, 20)
            PanelPadding.PaddingBottom = UDim.new(0, 15)
            PanelPadding.Parent = PanelList

            PanelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PanelFrame.Size = UDim2.new(1, 0, 0, PanelLayout.AbsoluteContentSize.Y + 65)
            end)

            local PanelElements = {}
            
            -- Helper to add element methods to a table
            local function ApplyMethods(target, list)
                function target:AddButton(Config)
                    local btn = OSX_Lib:Internal_AddButton(list, Config)
                    return target
                end
                function target:AddToggle(Config)
                    local tog = OSX_Lib:Internal_AddToggle(list, Config)
                    return target
                end
                function target:AddSlider(Config)
                    local sli = OSX_Lib:Internal_AddSlider(list, Config)
                    return target
                end
                function target:AddInput(Config)
                    local inp = OSX_Lib:Internal_AddInput(list, Config)
                    return target
                end
                function target:AddDropdown(Config)
                    local drop = OSX_Lib:Internal_AddDropdown(list, Config)
                    return target
                end
                function target:AddKeybind(Config)
                    local key = OSX_Lib:Internal_AddKeybind(list, Config)
                    return target
                end
                function target:AddLabel(Text)
                    local lab = OSX_Lib:Internal_AddLabel(list, Text)
                    return target
                end
                function target:AddSection(Text)
                    local sec = OSX_Lib:Internal_AddSection(list, Text)
                    return target
                end
                function target:AddParagraph(Title, Text)
                    local par = OSX_Lib:Internal_AddParagraph(list, Title, Text)
                    return target
                end
                function target:AddInfoLabel(Label, Value, Desc)
                    local info = OSX_Lib:Internal_AddInfoLabel(list, Label, Value, Desc)
                    return target
                end
                function target:AddWideButton(Config)
                    local wide = OSX_Lib:Internal_AddWideButton(list, Config)
                    return target
                end
                function target:AddColorPicker(Config)
                    local color = OSX_Lib:Internal_AddColorPicker(list, Config)
                    return target
                end
            end

            ApplyMethods(PanelElements, PanelList)
            return PanelElements
        end

        -- Add Direct Tab methods
        local function ApplyTabMethods(target, page)
            function target:AddButton(Config)
                OSX_Lib:Internal_AddButton(page, Config)
                return target
            end
            function target:AddToggle(Config)
                OSX_Lib:Internal_AddToggle(page, Config)
                return target
            end
            function target:AddSlider(Config)
                OSX_Lib:Internal_AddSlider(page, Config)
                return target
            end
            function target:AddInput(Config)
                OSX_Lib:Internal_AddInput(page, Config)
                return target
            end
            function target:AddDropdown(Config)
                OSX_Lib:Internal_AddDropdown(page, Config)
                return target
            end
            function target:AddKeybind(Config)
                OSX_Lib:Internal_AddKeybind(page, Config)
                return target
            end
            function target:AddLabel(Text)
                OSX_Lib:Internal_AddLabel(page, Text)
                return target
            end
            function target:AddSection(Text)
                OSX_Lib:Internal_AddSection(page, Text)
                return target
            end
            function target:AddParagraph(Title, Text)
                OSX_Lib:Internal_AddParagraph(page, Title, Text)
                return target
            end
            function target:AddColorPicker(Config)
                OSX_Lib:Internal_AddColorPicker(page, Config)
                return target
            end
        end

        ApplyTabMethods(Elements, TabPage)

        if not CurrentTab then Select() end
        if not CurrentTab then Select() end
        return Elements
    end

    local Window = {
        AddTab = function(self, TabConfig)
            return AddTab(TabConfig)
        end
    }

    return Window
end

print('OSX UI Library: Stealth Monochrome Update Loaded Successfully!')
return OSX_Lib
