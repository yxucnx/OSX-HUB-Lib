local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme / Constants (Customizable)
OSX_Lib.Theme = {
    MainBG = Color3.fromRGB(10, 10, 10),
    MainTransparency = 0.05,
    CardBG = Color3.fromRGB(24, 24, 24),
    CardTransparency = 0.25,
    Accent = Color3.fromRGB(255, 255, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(136, 136, 136),
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.94,
    SideItemActiveBG = Color3.fromRGB(255, 255, 255),
    SideItemActiveTransparency = 0.92,
    Font = Enum.Font.Gotham, -- Universal premium font
    FontBold = Enum.Font.GothamBold,
    CornerRadius = 15, -- Pronounced rounded corners
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

    function OSX_Lib:AddTab(TabConfig)
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

        -- AddPanel: Rounded card container (Matches website "Information" card)
        function Elements:AddPanel(PanelTitle)
            local PanelFrame = Instance.new("Frame")
            PanelFrame.Size = UDim2.new(1, 0, 0, 40) -- Auto-resizes based on Layout
            PanelFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            PanelFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            PanelFrame.Parent = TabPage

            local PanelCorner = Instance.new("UICorner")
            PanelCorner.CornerRadius = UDim.new(0, 15)
            PanelCorner.Parent = PanelFrame

            local PanelStroke = Instance.new("UIStroke")
            PanelStroke.Color = OSX_Lib.Theme.BorderColor
            PanelStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            PanelStroke.Thickness = 1
            PanelStroke.Parent = PanelFrame

            local PanelHeader = Instance.new("TextLabel")
            PanelHeader.Size = UDim2.new(1, 0, 0, 40)
            PanelHeader.Position = UDim2.new(0, 25, 0, 5)
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
            PanelLayout.Padding = UDim.new(0, 10) -- Increased padding between functions
            PanelLayout.Parent = PanelList

            local PanelPadding = Instance.new("UIPadding")
            PanelPadding.PaddingLeft = UDim.new(0, 25)
            PanelPadding.PaddingRight = UDim.new(0, 25)
            PanelPadding.PaddingBottom = UDim.new(0, 20)
            PanelPadding.Parent = PanelList

            PanelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PanelFrame.Size = UDim2.new(1, 0, 0, PanelLayout.AbsoluteContentSize.Y + 70)
            end)

            local PanelElements = {}

            function PanelElements:AddSection(SectionTitle)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Size = UDim2.new(1, 0, 0, 30)
                SectionFrame.BackgroundTransparency = 1
                SectionFrame.Parent = PanelList

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = SectionTitle:upper()
                Label.TextColor3 = OSX_Lib.Theme.TextDim
                Label.TextSize = 11
                Label.Font = OSX_Lib.Theme.FontBold
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SectionFrame

                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.Position = UDim2.new(0, 0, 1, -2)
                Line.BackgroundColor3 = OSX_Lib.Theme.BorderColor
                Line.BackgroundTransparency = 0.9
                Line.BorderSizePixel = 0
                Line.Parent = SectionFrame

                return PanelElements
            end

            function PanelElements:AddLabel(LabelText)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = LabelText
                Label.TextColor3 = OSX_Lib.Theme.TextMain
                Label.TextSize = 13
                Label.Font = OSX_Lib.Theme.Font
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = PanelList
                return PanelElements
            end

            function PanelElements:AddParagraph(ParaTitle, ParaText)
                local ParaFrame = Instance.new("Frame")
                ParaFrame.Size = UDim2.new(1, 0, 0, 60)
                ParaFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
                ParaFrame.BackgroundTransparency = 0.8
                ParaFrame.Parent = PanelList

                local ParaCorner = Instance.new("UICorner")
                ParaCorner.CornerRadius = UDim.new(0, 8)
                ParaCorner.Parent = ParaFrame

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, -20, 0, 20)
                Title.Position = UDim2.new(0, 10, 0, 8)
                Title.BackgroundTransparency = 1
                Title.Text = ParaTitle
                Title.TextColor3 = OSX_Lib.Theme.TextMain
                Title.TextSize = 13
                Title.Font = OSX_Lib.Theme.FontBold
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.Parent = ParaFrame

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -20, 0, 0)
                Text.Position = UDim2.new(0, 10, 0, 28)
                Text.BackgroundTransparency = 1
                Text.Text = ParaText
                Text.TextColor3 = OSX_Lib.Theme.TextDim
                Text.TextSize = 12
                Text.Font = OSX_Lib.Theme.Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.TextYAlignment = Enum.TextYAlignment.Top
                Text.TextWrapped = true
                Text.AutomaticSize = Enum.AutomaticSize.Y
                Text.Parent = ParaFrame

                Text:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    ParaFrame.Size = UDim2.new(1, 0, 0, Text.AbsoluteSize.Y + 40)
                end)

                return PanelElements
            end

            -- InfoLabel (Matches: "Owner: darkmxde")
            function PanelElements:AddInfoLabel(LabelText, ValueText, DescriptionStr)
                local BaseHeight = DescriptionStr and 50 or 35
                local InfoFrame = Instance.new("Frame")
                InfoFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
                InfoFrame.BackgroundTransparency = 1
                InfoFrame.Parent = PanelList

                local TopLabel = Instance.new("TextLabel")
                TopLabel.Size = UDim2.new(0.4, 0, 0, 20)
                TopLabel.Position = UDim2.new(0, 0, 0, 5)
                TopLabel.BackgroundTransparency = 1
                TopLabel.Text = LabelText
                TopLabel.TextColor3 = OSX_Lib.Theme.TextDim
                TopLabel.TextSize = 13
                TopLabel.Font = OSX_Lib.Theme.Font
                TopLabel.TextXAlignment = Enum.TextXAlignment.Left
                TopLabel.Parent = InfoFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0.6, 0, 0, 20)
                ValueLabel.Position = UDim2.new(0.4, 0, 0, 5)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = ValueText
                ValueLabel.TextColor3 = OSX_Lib.Theme.TextMain
                ValueLabel.TextSize = 13
                ValueLabel.Font = OSX_Lib.Theme.FontBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValueLabel.Parent = InfoFrame

                if DescriptionStr then
                    local InfoDesc = Instance.new("TextLabel")
                    InfoDesc.Size = UDim2.new(1, 0, 0, 18)
                    InfoDesc.Position = UDim2.new(0, 0, 0, 25)
                    InfoDesc.BackgroundTransparency = 1
                    InfoDesc.Text = DescriptionStr
                    InfoDesc.TextColor3 = OSX_Lib.Theme.TextDim
                    InfoDesc.TextSize = 11
                    InfoDesc.Font = OSX_Lib.Theme.Font
                    InfoDesc.TextXAlignment = Enum.TextXAlignment.Left
                    InfoDesc.Parent = InfoFrame
                end

                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Divider.Position = UDim2.new(0, 0, 1, 0)
                Divider.BackgroundColor3 = OSX_Lib.Theme.BorderColor
                Divider.BackgroundTransparency = 0.95
                Divider.BorderSizePixel = 0
                Divider.Parent = InfoFrame

                return PanelElements
            end

            -- Wide Button (Matches: "Join Telegram" / "Discord Server")
            function PanelElements:AddWideButton(BtnConfig)
                BtnConfig = BtnConfig or {}
                local TitleStr = BtnConfig.Title or "Button"
                local DescriptionStr = BtnConfig.Description
                local Callback = BtnConfig.Callback or function() end

                local BaseHeight = DescriptionStr and 65 or 45
                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
                BtnFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                BtnFrame.BackgroundTransparency = 0.5
                BtnFrame.Parent = PanelList

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 12)
                BtnCorner.Parent = BtnFrame

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = OSX_Lib.Theme.BorderColor
                BtnStroke.Transparency = 0.9
                BtnStroke.Parent = BtnFrame

                local RealBtn = Instance.new("TextButton")
                RealBtn.Size = UDim2.new(1, 0, 1, 0)
                RealBtn.BackgroundTransparency = 1
                RealBtn.Text = ""
                RealBtn.Parent = BtnFrame

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Size = UDim2.new(1, 0, 0, 20)
                BtnLabel.Position = UDim2.new(0, 0, 0.5, DescriptionStr and -18 or -10)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = TitleStr
                BtnLabel.TextColor3 = OSX_Lib.Theme.TextMain
                BtnLabel.TextSize = 13
                BtnLabel.Font = OSX_Lib.Theme.FontBold
                BtnLabel.Parent = BtnFrame
                
                if DescriptionStr then
                    local BtnDesc = Instance.new("TextLabel")
                    BtnDesc.Size = UDim2.new(1, 0, 0, 18)
                    BtnDesc.Position = UDim2.new(0, 0, 0.5, 2)
                    BtnDesc.BackgroundTransparency = 1
                    BtnDesc.Text = DescriptionStr
                    BtnDesc.TextColor3 = OSX_Lib.Theme.TextDim
                    BtnDesc.TextSize = 11
                    BtnDesc.Font = OSX_Lib.Theme.Font
                    BtnDesc.Parent = BtnFrame
                end

                RealBtn.MouseEnter:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                end)
                RealBtn.MouseLeave:Connect(function()
                    TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                end)
                RealBtn.MouseButton1Click:Connect(Callback)

                return PanelElements
            end

            -- Toggle (Panel Version)
            function PanelElements:AddToggle(TogConfig)
                TogConfig = TogConfig or {}
                local TitleStr = TogConfig.Title or "Toggle"
                local DescriptionStr = TogConfig.Description
                local Default = TogConfig.Default or false
                local Callback = TogConfig.Callback or function() end
                local State = Default

                local BaseHeight = DescriptionStr and 75 or 55
                local TogFrame = Instance.new("Frame")
                TogFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
                TogFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
                TogFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
                TogFrame.Parent = PanelList

                local TogCorner = Instance.new("UICorner")
                TogCorner.CornerRadius = UDim.new(0, 12)
                TogCorner.Parent = TogFrame

                local TogStroke = Instance.new("UIStroke")
                TogStroke.Color = OSX_Lib.Theme.BorderColor
                TogStroke.Transparency = OSX_Lib.Theme.BorderTransparency
                TogStroke.Thickness = 1
                TogStroke.Parent = TogFrame

                local TogLabel = Instance.new("TextLabel")
                TogLabel.Size = UDim2.new(1, -70, 0, 22)
                TogLabel.Position = UDim2.new(0, 15, 0, (BaseHeight - 22) / 2 - (DescriptionStr and 10 or 0))
                TogLabel.BackgroundTransparency = 1
                TogLabel.Text = TitleStr
                TogLabel.TextColor3 = OSX_Lib.Theme.TextMain
                TogLabel.TextSize = 13
                TogLabel.Font = OSX_Lib.Theme.FontBold
                TogLabel.TextXAlignment = Enum.TextXAlignment.Left
                TogLabel.Parent = TogFrame

                if DescriptionStr then
                    local TogDesc = Instance.new("TextLabel")
                    TogDesc.Size = UDim2.new(1, -70, 0, 18)
                    TogDesc.Position = UDim2.new(0, 15, 0, (BaseHeight / 2) + 2)
                    TogDesc.BackgroundTransparency = 1
                    TogDesc.Text = DescriptionStr
                    TogDesc.TextColor3 = OSX_Lib.Theme.TextDim
                    TogDesc.TextSize = 11
                    TogDesc.Font = OSX_Lib.Theme.Font
                    TogDesc.TextXAlignment = Enum.TextXAlignment.Left
                    TogDesc.Parent = TogFrame
                end

                local ToggleBg = Instance.new("Frame")
                ToggleBg.Size = UDim2.new(0, 42, 0, 22)
                ToggleBg.Position = UDim2.new(1, -55, 0.5, -11)
                ToggleBg.BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
                ToggleBg.Parent = TogFrame

                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCorner.Parent = ToggleBg

                local ToggleDot = Instance.new("Frame")
                ToggleDot.Size = UDim2.new(0, 16, 0, 16)
                ToggleDot.Position = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                ToggleDot.BackgroundColor3 = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
                ToggleDot.Parent = ToggleBg

                local ToggleDotCorner = Instance.new("UICorner")
                ToggleDotCorner.CornerRadius = UDim.new(1, 0)
                ToggleDotCorner.Parent = ToggleDot

                local ClickArea = Instance.new("TextButton")
                ClickArea.Size = UDim2.new(1, 0, 1, 0)
                ClickArea.BackgroundTransparency = 1
                ClickArea.Text = ""
                ClickArea.Parent = TogFrame

                ClickArea.MouseButton1Click:Connect(function()
                    State = not State
                    local EndPos = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                    local EndColor = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
                    local DotColor = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)

                    TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = EndPos, BackgroundColor3 = DotColor}):Play()
                    TweenService:Create(ToggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = EndColor}):Play()
                    
                    Callback(State)
                end)

                return PanelElements
            end

            -- Slider (Panel Version)
            function PanelElements:AddSlider(SliConfig)
                SliConfig = SliConfig or {}
                local TitleStr = SliConfig.Title or "Slider"
                local DescriptionStr = SliConfig.Description
                local Default = SliConfig.Default or 50
                local Min = SliConfig.Min or 0
                local Max = SliConfig.Max or 100
                local Rounding = SliConfig.Rounding or 1
                local Callback = SliConfig.Callback or function() end
                local Value = Default

                local BaseHeight = DescriptionStr and 90 or 70
                local SliFrame = Instance.new("Frame")
                SliFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
                SliFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
                SliFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
                SliFrame.Parent = PanelList

                local SliCorner = Instance.new("UICorner")
                SliCorner.CornerRadius = UDim.new(0, 12)
                SliCorner.Parent = SliFrame

                local SliStroke = Instance.new("UIStroke")
                SliStroke.Color = OSX_Lib.Theme.BorderColor
                SliStroke.Transparency = OSX_Lib.Theme.BorderTransparency
                SliStroke.Thickness = 1
                SliStroke.Parent = SliFrame

                local SliLabel = Instance.new("TextLabel")
                SliLabel.Size = UDim2.new(1, -70, 0, 22)
                SliLabel.Position = UDim2.new(0, 15, 0, 12)
                SliLabel.BackgroundTransparency = 1
                SliLabel.Text = TitleStr
                SliLabel.TextColor3 = OSX_Lib.Theme.TextMain
                SliLabel.TextSize = 13
                SliLabel.Font = OSX_Lib.Theme.FontBold
                SliLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliLabel.Parent = SliFrame

                if DescriptionStr then
                    local SliDesc = Instance.new("TextLabel")
                    SliDesc.Size = UDim2.new(1, -70, 0, 18)
                    SliDesc.Position = UDim2.new(0, 15, 0, 32)
                    SliDesc.BackgroundTransparency = 1
                    SliDesc.Text = DescriptionStr
                    SliDesc.TextColor3 = OSX_Lib.Theme.TextDim
                    SliDesc.TextSize = 11
                    SliDesc.Font = OSX_Lib.Theme.Font
                    SliDesc.TextXAlignment = Enum.TextXAlignment.Left
                    SliDesc.Parent = SliFrame
                end

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 50, 0, 22)
                ValueLabel.Position = UDim2.new(1, -65, 0, 12)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(Value)
                ValueLabel.TextColor3 = OSX_Lib.Theme.Accent
                ValueLabel.TextSize = 12
                ValueLabel.Font = OSX_Lib.Theme.FontBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliFrame

                local SliderBg = Instance.new("Frame")
                SliderBg.Size = UDim2.new(1, -30, 0, 4)
                SliderBg.Position = UDim2.new(0, 15, 0, BaseHeight - 20)
                SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                SliderBg.Parent = SliFrame

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(1, 0)
                SliderCorner.Parent = SliderBg

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = OSX_Lib.Theme.Accent
                SliderFill.Parent = SliderBg

                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill

                local SliderDot = Instance.new("Frame")
                SliderDot.Size = UDim2.new(0, 12, 0, 12)
                SliderDot.Position = UDim2.new(1, -6, 0.5, -6)
                SliderDot.BackgroundColor3 = OSX_Lib.Theme.Accent
                SliderDot.Parent = SliderFill

                local SliderDotCorner = Instance.new("UICorner")
                SliderDotCorner.CornerRadius = UDim.new(1, 0)
                SliderDotCorner.Parent = SliderDot

                local SliderStroke = Instance.new("UIStroke")
                SliderStroke.Color = Color3.fromRGB(0,0,0)
                SliderStroke.Transparency = 0.5
                SliderStroke.Parent = SliderDot

                local Dragging = false
                local function Move(Input)
                    local Pos = math.clamp((Input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    Value = math.floor((Min + ((Max - Min) * Pos)) * (10^Rounding)) / (10^Rounding)
                    ValueLabel.Text = tostring(Value)
                    TweenService:Create(SliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quart), {Size = UDim2.new(Pos, 0, 1, 0)}):Play()
                    Callback(Value)
                end

                SliderBg.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        Move(Input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        Move(Input)
                    end
                end)

                return PanelElements
            end

            -- Color Picker (Panel Version)
            function PanelElements:AddColorPicker(ColConfig)
                ColConfig = ColConfig or {}
                local TitleStr = ColConfig.Title or "Color Picker"
                local DescriptionStr = ColConfig.Description
                local DefaultColor = ColConfig.Default or Color3.fromRGB(255, 255, 255)
                local Callback = ColConfig.Callback or function() end
                
                local CurrentColor = DefaultColor
                local BaseHeight = DescriptionStr and 75 or 55
                local ExpandedHeight = BaseHeight + 110
                local IsExpanded = false

                local ColFrame = Instance.new("Frame")
                ColFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
                ColFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
                ColFrame.ClipsDescendants = true
                ColFrame.Parent = PanelList

                local ColCorner = Instance.new("UICorner")
                ColCorner.CornerRadius = UDim.new(0, 12)
                ColCorner.Parent = ColFrame

                local ColStroke = Instance.new("UIStroke")
                ColStroke.Color = OSX_Lib.Theme.BorderColor
                ColStroke.Transparency = OSX_Lib.Theme.BorderTransparency
                ColStroke.Parent = ColFrame

                local ColLabel = Instance.new("TextLabel")
                ColLabel.Size = UDim2.new(1, -120, 0, 22)
                ColLabel.Position = UDim2.new(0, 15, 0, (BaseHeight - 22) / 2 - (DescriptionStr and 10 or 0))
                ColLabel.BackgroundTransparency = 1
                ColLabel.Text = TitleStr
                ColLabel.TextColor3 = OSX_Lib.Theme.TextMain
                ColLabel.TextSize = 13
                ColLabel.Font = OSX_Lib.Theme.FontBold
                ColLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColLabel.Parent = ColFrame

                if DescriptionStr then
                    local ColDesc = Instance.new("TextLabel")
                    ColDesc.Size = UDim2.new(1, -120, 0, 18)
                    ColDesc.Position = UDim2.new(0, 15, 0, (BaseHeight / 2) + 2)
                    ColDesc.BackgroundTransparency = 1
                    ColDesc.Text = DescriptionStr
                    ColDesc.TextColor3 = OSX_Lib.Theme.TextDim
                    ColDesc.TextSize = 11
                    ColDesc.Font = OSX_Lib.Theme.Font
                    ColDesc.TextXAlignment = Enum.TextXAlignment.Left
                    ColDesc.Parent = ColFrame
                end

                local PreviewArea = Instance.new("Frame")
                PreviewArea.Size = UDim2.new(0, 45, 0, 25)
                PreviewArea.Position = UDim2.new(1, -60, 0, (BaseHeight - 25) / 2)
                PreviewArea.BackgroundColor3 = DefaultColor
                PreviewArea.Parent = ColFrame

                local PACorner = Instance.new("UICorner")
                PACorner.CornerRadius = UDim.new(0, 4)
                PACorner.Parent = PreviewArea

                local PAStroke = Instance.new("UIStroke")
                PAStroke.Color = OSX_Lib.Theme.BorderColor
                PAStroke.Thickness = 1
                PAStroke.Parent = PreviewArea

                local OpenBtn = Instance.new("TextButton")
                OpenBtn.Size = UDim2.new(1, 0, 1, 0)
                OpenBtn.BackgroundTransparency = 1
                OpenBtn.Text = ""
                OpenBtn.Parent = PreviewArea

                -- Expansion Area
                local ExpandArea = Instance.new("Frame")
                ExpandArea.Size = UDim2.new(1, -30, 0, 95)
                ExpandArea.Position = UDim2.new(0, 15, 0, BaseHeight + 5)
                ExpandArea.BackgroundTransparency = 1
                ExpandArea.Parent = ColFrame

                local function CreateSlider(Title, InternalColor, YPos)
                    local SLabel = Instance.new("TextLabel")
                    SLabel.Size = UDim2.new(0, 15, 0, 20)
                    SLabel.Position = UDim2.new(0, 0, 0, YPos)
                    SLabel.BackgroundTransparency = 1
                    SLabel.Text = Title
                    SLabel.TextColor3 = OSX_Lib.Theme.TextDim
                    SLabel.TextSize = 11
                    SLabel.Font = OSX_Lib.Theme.FontBold
                    SLabel.Parent = ExpandArea

                    local SBg = Instance.new("Frame")
                    SBg.Size = UDim2.new(1, -60, 0, 4)
                    SBg.Position = UDim2.new(0, 25, 0, YPos + 8)
                    SBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    SBg.Parent = ExpandArea

                    local SFill = Instance.new("Frame")
                    local initialVal = (InternalColor == "R" and DefaultColor.R) or (InternalColor == "G" and DefaultColor.G) or DefaultColor.B
                    SFill.Size = UDim2.new(initialVal, 0, 1, 0)
                    SFill.BackgroundColor3 = (InternalColor == "R" and Color3.fromRGB(200,50,50)) or (InternalColor == "G" and Color3.fromRGB(50,200,50)) or Color3.fromRGB(50,50,200)
                    SFill.Parent = SBg
                    
                    local SDot = Instance.new("Frame")
                    SDot.Size = UDim2.new(0, 10, 0, 10)
                    SDot.Position = UDim2.new(1, -5, 0.5, -5)
                    SDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    SDot.Parent = SFill
                    Instance.new("UICorner", SDot).CornerRadius = UDim.new(1,0)

                    local Dragging = false
                    local function Update()
                        local r = InternalColor == "R" and SFill.Size.X.Scale or CurrentColor.R
                        local g = InternalColor == "G" and SFill.Size.X.Scale or CurrentColor.G
                        local b = InternalColor == "B" and SFill.Size.X.Scale or CurrentColor.B
                        CurrentColor = Color3.new(r, g, b)
                        PreviewArea.BackgroundColor3 = CurrentColor
                        Callback(CurrentColor)
                    end

                    SBg.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
                    end)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                            local percent = math.clamp((i.Position.X - SBg.AbsolutePosition.X) / SBg.AbsoluteSize.X, 0, 1)
                            SFill.Size = UDim2.new(percent, 0, 1, 0)
                            Update()
                        end
                    end)
                end

                CreateSlider("R", "R", 10)
                CreateSlider("G", "G", 40)
                CreateSlider("B", "B", 70)

                OpenBtn.MouseButton1Click:Connect(function()
                    IsExpanded = not IsExpanded
                    TweenService:Create(ColFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, IsExpanded and ExpandedHeight or BaseHeight)}):Play()
                end)

                return PanelElements
            end

            return PanelElements
        end

        function Elements:AddToggle(TogConfig)
            TogConfig = TogConfig or {}
            local TitleStr = TogConfig.Title or "Toggle"
            local DescriptionStr = TogConfig.Description
            local Default = TogConfig.Default or false
            local Callback = TogConfig.Callback or function() end
            local State = Default

            local BaseHeight = DescriptionStr and 75 or 55
            local TogFrame = Instance.new("Frame")
            TogFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
            TogFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            TogFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            TogFrame.Parent = TabPage

            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(0, 12)
            TogCorner.Parent = TogFrame

            local TogStroke = Instance.new("UIStroke")
            TogStroke.Color = OSX_Lib.Theme.BorderColor
            TogStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            TogStroke.Thickness = 1
            TogStroke.Parent = TogFrame

            local TogLabel = Instance.new("TextLabel")
            TogLabel.Size = UDim2.new(1, -70, 0, 22)
            TogLabel.Position = UDim2.new(0, 20, 0, (BaseHeight - 22) / 2 - (DescriptionStr and 10 or 0))
            TogLabel.BackgroundTransparency = 1
            TogLabel.Text = TitleStr
            TogLabel.TextColor3 = OSX_Lib.Theme.TextMain
            TogLabel.TextSize = 14
            TogLabel.Font = OSX_Lib.Theme.FontBold
            TogLabel.TextXAlignment = Enum.TextXAlignment.Left
            TogLabel.Parent = TogFrame

            if DescriptionStr then
                local TogDesc = Instance.new("TextLabel")
                TogDesc.Size = UDim2.new(1, -70, 0, 18)
                TogDesc.Position = UDim2.new(0, 20, 0, (BaseHeight / 2) + 2)
                TogDesc.BackgroundTransparency = 1
                TogDesc.Text = DescriptionStr
                TogDesc.TextColor3 = OSX_Lib.Theme.TextDim
                TogDesc.TextSize = 12
                TogDesc.Font = OSX_Lib.Theme.Font
                TogDesc.TextXAlignment = Enum.TextXAlignment.Left
                TogDesc.Parent = TogFrame
            end

            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(0, 42, 0, 22)
            ToggleBg.Position = UDim2.new(1, -62, 0.5, -11)
            ToggleBg.BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
            ToggleBg.Parent = TogFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCorner.Parent = ToggleBg

            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size = UDim2.new(0, 16, 0, 16)
            ToggleDot.Position = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            ToggleDot.BackgroundColor3 = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            ToggleDot.Parent = ToggleBg

            local ToggleDotCorner = Instance.new("UICorner")
            ToggleDotCorner.CornerRadius = UDim.new(1, 0)
            ToggleDotCorner.Parent = ToggleDot

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.Parent = TogFrame

            ClickArea.MouseButton1Click:Connect(function()
                State = not State
                local EndPos = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                local EndColor = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
                local DotColor = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)

                TweenService:Create(ToggleDot, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = EndPos, BackgroundColor3 = DotColor}):Play()
                TweenService:Create(ToggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = EndColor}):Play()
                
                Callback(State)
            end)

            return Elements
        end

        function Elements:AddSlider(SliConfig)
            SliConfig = SliConfig or {}
            local TitleStr = SliConfig.Title or "Slider"
            local DescriptionStr = SliConfig.Description
            local Default = SliConfig.Default or 50
            local Min = SliConfig.Min or 0
            local Max = SliConfig.Max or 100
            local Rounding = SliConfig.Rounding or 1
            local Callback = SliConfig.Callback or function() end
            local Value = Default

            local SliFrame = Instance.new("Frame")
            SliFrame.Size = UDim2.new(1, 0, 0, DescriptionStr and 85 or 65)
            SliFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            SliFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            SliFrame.Parent = TabPage

            local SliCorner = Instance.new("UICorner")
            SliCorner.CornerRadius = UDim.new(0, 12)
            SliCorner.Parent = SliFrame

            local SliStroke = Instance.new("UIStroke")
            SliStroke.Color = OSX_Lib.Theme.BorderColor
            SliStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            SliStroke.Thickness = 1
            SliStroke.Parent = SliFrame

            local SliLabel = Instance.new("TextLabel")
            SliLabel.Size = UDim2.new(1, -20, 0, 25)
            SliLabel.Position = UDim2.new(0, 20, 0, 10)
            SliLabel.BackgroundTransparency = 1
            SliLabel.Text = TitleStr
            SliLabel.TextColor3 = OSX_Lib.Theme.TextMain
            SliLabel.TextSize = 14
            SliLabel.Font = OSX_Lib.Theme.FontBold
            SliLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliLabel.Parent = SliFrame

            if DescriptionStr then
                local SliDesc = Instance.new("TextLabel")
                SliDesc.Size = UDim2.new(1, -20, 0, 20)
                SliDesc.Position = UDim2.new(0, 20, 0, 30)
                SliDesc.BackgroundTransparency = 1
                SliDesc.Text = DescriptionStr
                SliDesc.TextColor3 = OSX_Lib.Theme.TextDim
                SliDesc.TextSize = 12
                SliDesc.Font = OSX_Lib.Theme.Font
                SliDesc.TextXAlignment = Enum.TextXAlignment.Left
                SliDesc.Parent = SliFrame
            end

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -70, 0, 10)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = OSX_Lib.Theme.TextDim
            ValueLabel.TextSize = 13
            ValueLabel.Font = OSX_Lib.Theme.Font
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliFrame

            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, -40, 0, 5)
            SliderBg.Position = UDim2.new(0, 20, 0, DescriptionStr and 68 or 48)
            SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SliderBg.Parent = SliFrame

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(1, 0)
            SliderCorner.Parent = SliderBg

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = OSX_Lib.Theme.Accent
            SliderFill.Parent = SliderBg

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local SliderDot = Instance.new("Frame")
            SliderDot.Size = UDim2.new(0, 14, 0, 14)
            SliderDot.Position = UDim2.new(1, -7, 0.5, -7)
            SliderDot.BackgroundColor3 = OSX_Lib.Theme.Accent
            SliderDot.Parent = SliderFill

            local SliderDotCorner = Instance.new("UICorner")
            SliderDotCorner.CornerRadius = UDim.new(1, 0)
            SliderDotCorner.Parent = SliderDot

            local Dragging = false
            local function Move(Input)
                local Pos = math.clamp((Input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                Value = math.floor((Min + ((Max - Min) * Pos)) * (10^Rounding)) / (10^Rounding)
                ValueLabel.Text = tostring(Value)
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(Pos, 0, 1, 0)}):Play()
                Callback(Value)
            end

            SliderBg.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Move(Input)
                end
            end)
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Move(Input)
                end
            end)

            return PanelElements
        end

        function PanelElements:AddDropdown(DropConfig)
            DropConfig = DropConfig or {}
            local TitleStr = DropConfig.Title or "Dropdown"
            local DescriptionStr = DropConfig.Description
            local Options = DropConfig.Values or {}
            local Default = DropConfig.Default or 1
            local Callback = DropConfig.Callback or function() end

            local BaseHeight = DescriptionStr and 85 or 65
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
            DropFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            DropFrame.Parent = PanelList

            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 8)
            DropCorner.Parent = DropFrame

            local DropStroke = Instance.new("UIStroke")
            DropStroke.Color = OSX_Lib.Theme.BorderColor
            DropStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            DropStroke.Thickness = 1
            DropStroke.Parent = DropFrame

            local DropLabel = Instance.new("TextLabel")
            DropLabel.Size = UDim2.new(1, -20, 0, 25)
            DropLabel.Position = UDim2.new(0, 20, 0, 10)
            DropLabel.BackgroundTransparency = 1
            DropLabel.Text = TitleStr
            DropLabel.TextColor3 = OSX_Lib.Theme.TextMain
            DropLabel.TextSize = 14
            DropLabel.Font = OSX_Lib.Theme.FontBold
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.Parent = DropFrame

            if DescriptionStr then
                local DropDesc = Instance.new("TextLabel")
                DropDesc.Size = UDim2.new(1, -20, 0, 20)
                DropDesc.Position = UDim2.new(0, 20, 0, 30)
                DropDesc.BackgroundTransparency = 1
                DropDesc.Text = DescriptionStr
                DropDesc.TextColor3 = OSX_Lib.Theme.TextDim
                DropDesc.TextSize = 12
                DropDesc.Font = OSX_Lib.Theme.Font
                DropDesc.TextXAlignment = Enum.TextXAlignment.Left
                DropDesc.Parent = DropFrame
            end

            local SelectedBtn = Instance.new("TextButton")
            SelectedBtn.Size = UDim2.new(0, 160, 0, 30)
            SelectedBtn.Position = UDim2.new(1, -180, 0, (BaseHeight - 30) / 2)
            SelectedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SelectedBtn.Text = Options[Default] or "None"
            SelectedBtn.TextColor3 = OSX_Lib.Theme.TextMain
            SelectedBtn.TextSize = 13
            SelectedBtn.Font = OSX_Lib.Theme.FontBold
            SelectedBtn.AutoButtonColor = false
            SelectedBtn.Parent = DropFrame

            local SelCorner = Instance.new("UICorner")
            SelCorner.CornerRadius = UDim.new(0, 6)
            SelCorner.Parent = SelectedBtn
            
            local SelStroke = Instance.new("UIStroke")
            SelStroke.Color = OSX_Lib.Theme.BorderColor
            SelStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            SelStroke.Parent = SelectedBtn

            local IconLabel = Instance.new("TextLabel")
            IconLabel.Size = UDim2.new(0, 30, 1, 0)
            IconLabel.Position = UDim2.new(1, -30, 0, 0)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Text = "โ–ผ"
            IconLabel.TextColor3 = OSX_Lib.Theme.TextDim
            IconLabel.TextSize = 12
            IconLabel.Font = Enum.Font.Gotham
            IconLabel.Parent = SelectedBtn

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            OptionsContainer.Position = UDim2.new(0, 0, 1, 5)
            OptionsContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            OptionsContainer.ClipsDescendants = true
            OptionsContainer.Visible = false
            OptionsContainer.ZIndex = 5
            OptionsContainer.Parent = SelectedBtn

            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, 6)
            OptCorner.Parent = OptionsContainer
            local OptStroke = Instance.new("UIStroke")
            OptStroke.Color = OSX_Lib.Theme.BorderColor
            OptStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            OptStroke.Parent = OptionsContainer

            local OptList = Instance.new("UIListLayout")
            OptList.SortOrder = Enum.SortOrder.LayoutOrder
            OptList.Parent = OptionsContainer

            local Open = false
            local ItemHeight = 30

            SelectedBtn.MouseButton1Click:Connect(function()
                Open = not Open
                OptionsContainer.Visible = true
                IconLabel.Rotation = Open and 180 or 0
                TweenService:Create(OptionsContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, Open and (#Options * ItemHeight) or 0)}):Play()
                
                -- Support Dropdown Pushing logic by expanding parent dropdown container
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, BaseHeight + (Open and (#Options * ItemHeight + 5) or 0))}):Play()
                
                if not Open then task.delay(0.2, function() OptionsContainer.Visible = false end) end
            end)

            for i, opt in ipairs(Options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
                OptBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                OptBtn.BackgroundTransparency = 0
                OptBtn.BorderSizePixel = 0
                OptBtn.Text = opt
                OptBtn.TextColor3 = OSX_Lib.Theme.TextDim
                OptBtn.TextSize = 13
                OptBtn.Font = OSX_Lib.Theme.Font
                OptBtn.ZIndex = 6
                OptBtn.Parent = OptionsContainer

                OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = OSX_Lib.Theme.TextMain; OptBtn.BackgroundColor3 = Color3.fromRGB(30,30,30) end)
                OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = OSX_Lib.Theme.TextDim; OptBtn.BackgroundColor3 = Color3.fromRGB(22,22,22) end)

                OptBtn.MouseButton1Click:Connect(function()
                    SelectedBtn.Text = opt
                    Open = false
                    IconLabel.Rotation = 0
                    TweenService:Create(OptionsContainer, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, BaseHeight)}):Play()
                    task.delay(0.2, function() OptionsContainer.Visible = false end)
                    Callback(opt)
                end)
            end

            return PanelElements
        end

        function PanelElements:AddKeybind(KeyConfig)
            KeyConfig = KeyConfig or {}
            local TitleStr = KeyConfig.Title or "Keybind"
            local DescriptionStr = KeyConfig.Description
            local DefaultKey = KeyConfig.Default or "E"
            local Callback = KeyConfig.Callback or function() end

            local BaseHeight = DescriptionStr and 85 or 65
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
            KeyFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            KeyFrame.Parent = PanelList

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 8)
            KeyCorner.Parent = KeyFrame
            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = OSX_Lib.Theme.BorderColor
            KeyStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            KeyStroke.Thickness = 1
            KeyStroke.Parent = KeyFrame

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Size = UDim2.new(1, -20, 0, 25)
            KeyLabel.Position = UDim2.new(0, 20, 0, 10)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Text = TitleStr
            KeyLabel.TextColor3 = OSX_Lib.Theme.TextMain
            KeyLabel.TextSize = 14
            KeyLabel.Font = OSX_Lib.Theme.FontBold
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyLabel.Parent = KeyFrame

            if DescriptionStr then
                local KeyDesc = Instance.new("TextLabel")
                KeyDesc.Size = UDim2.new(1, -20, 0, 20)
                KeyDesc.Position = UDim2.new(0, 20, 0, 30)
                KeyDesc.BackgroundTransparency = 1
                KeyDesc.Text = DescriptionStr
                KeyDesc.TextColor3 = OSX_Lib.Theme.TextDim
                KeyDesc.TextSize = 12
                KeyDesc.Font = OSX_Lib.Theme.Font
                KeyDesc.TextXAlignment = Enum.TextXAlignment.Left
                KeyDesc.Parent = KeyFrame
            end

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 100, 0, 30)
            BindBtn.Position = UDim2.new(1, -120, 0, (BaseHeight - 30) / 2)
            BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            BindBtn.Text = tostring(DefaultKey)
            BindBtn.TextColor3 = OSX_Lib.Theme.TextMain
            BindBtn.TextSize = 13
            BindBtn.Font = OSX_Lib.Theme.FontBold
            BindBtn.Parent = KeyFrame

            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 6)
            BindCorner.Parent = BindBtn
            local BindStroke = Instance.new("UIStroke")
            BindStroke.Color = OSX_Lib.Theme.BorderColor
            BindStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            BindStroke.Parent = BindBtn

            local CurrentKey = DefaultKey
            local IsBinding = false

            BindBtn.MouseButton1Click:Connect(function()
                IsBinding = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = OSX_Lib.Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if IsBinding and not processed then
                    local keyName = nil
                    if input.UserInputType == Enum.UserInputType.Keyboard then keyName = input.KeyCode.Name end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then keyName = "MB1" end
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then keyName = "MB2" end
                    if input.UserInputType == Enum.UserInputType.MouseButton3 then keyName = "MB3" end
                    
                    if keyName then
                        CurrentKey = keyName
                        BindBtn.Text = keyName
                        BindBtn.TextColor3 = OSX_Lib.Theme.TextMain
                        IsBinding = false
                        Callback(keyName)
                    end
                elseif not IsBinding and not processed then
                    local inputName = (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name) or 
                                      (input.UserInputType == Enum.UserInputType.MouseButton1 and "MB1") or
                                      (input.UserInputType == Enum.UserInputType.MouseButton2 and "MB2") or
                                      (input.UserInputType == Enum.UserInputType.MouseButton3 and "MB3")
                                      
                    if inputName == CurrentKey then Callback(inputName, true) end
                end
            end)

            return PanelElements
        end

        function PanelElements:AddInput(InputConfig)
            InputConfig = InputConfig or {}
            local TitleStr = InputConfig.Title or "Input"
            local DescriptionStr = InputConfig.Description
            local DefaultStr = InputConfig.Default or ""
            local Callback = InputConfig.Callback or function() end

            local BaseHeight = DescriptionStr and 85 or 65
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
            InputFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            InputFrame.Parent = PanelList

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 8)
            InputCorner.Parent = InputFrame
            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color = OSX_Lib.Theme.BorderColor
            InputStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            InputStroke.Thickness = 1
            InputStroke.Parent = InputFrame

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Size = UDim2.new(1, -20, 0, 25)
            InputLabel.Position = UDim2.new(0, 20, 0, 10)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Text = TitleStr
            InputLabel.TextColor3 = OSX_Lib.Theme.TextMain
            InputLabel.TextSize = 14
            InputLabel.Font = OSX_Lib.Theme.FontBold
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = InputFrame

            if DescriptionStr then
                local InputDesc = Instance.new("TextLabel")
                InputDesc.Size = UDim2.new(1, -20, 0, 20)
                InputDesc.Position = UDim2.new(0, 20, 0, 30)
                InputDesc.BackgroundTransparency = 1
                InputDesc.Text = DescriptionStr
                InputDesc.TextColor3 = OSX_Lib.Theme.TextDim
                InputDesc.TextSize = 12
                InputDesc.Font = OSX_Lib.Theme.Font
                InputDesc.TextXAlignment = Enum.TextXAlignment.Left
                InputDesc.Parent = InputFrame
            end

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0, 160, 0, 30)
            TextBox.Position = UDim2.new(1, -180, 0, (BaseHeight - 30) / 2)
            TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TextBox.Text = DefaultStr
            TextBox.PlaceholderText = "..."
            TextBox.TextColor3 = OSX_Lib.Theme.TextMain
            TextBox.TextSize = 13
            TextBox.Font = OSX_Lib.Theme.Font
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = InputFrame

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 6)
            TBCorner.Parent = TextBox
            local TBStroke = Instance.new("UIStroke")
            TBStroke.Color = OSX_Lib.Theme.BorderColor
            TBStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            TBStroke.Parent = TextBox

            TextBox.FocusLost:Connect(function(enterPressed)
                Callback(TextBox.Text)
            end)

            return PanelElements
        end

        function PanelElements:AddButton(BtnConfig)
            BtnConfig = BtnConfig or {}
            local TitleStr = BtnConfig.Title or "Button"
            local DescriptionStr = BtnConfig.Description
            local Callback = BtnConfig.Callback or function() end

            local BaseHeight = DescriptionStr and 85 or 65
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, BaseHeight)
            BtnFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            BtnFrame.Parent = PanelList

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 8)
            BtnCorner.Parent = BtnFrame
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = OSX_Lib.Theme.BorderColor
            BtnStroke.Transparency = OSX_Lib.Theme.BorderTransparency
            BtnStroke.Thickness = 1
            BtnStroke.Parent = BtnFrame

            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Size = UDim2.new(1, -20, 0, 25)
            BtnLabel.Position = UDim2.new(0, 20, 0, 10)
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Text = TitleStr
            BtnLabel.TextColor3 = OSX_Lib.Theme.TextMain
            BtnLabel.TextSize = 14
            BtnLabel.Font = OSX_Lib.Theme.FontBold
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            BtnLabel.Parent = BtnFrame

            if DescriptionStr then
                local BtnDesc = Instance.new("TextLabel")
                BtnDesc.Size = UDim2.new(1, -20, 0, 20)
                BtnDesc.Position = UDim2.new(0, 20, 0, 30)
                BtnDesc.BackgroundTransparency = 1
                BtnDesc.Text = DescriptionStr
                BtnDesc.TextColor3 = OSX_Lib.Theme.TextDim
                BtnDesc.TextSize = 12
                BtnDesc.Font = OSX_Lib.Theme.Font
                BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
                BtnDesc.Parent = BtnFrame
            end

            local RealBtn = Instance.new("TextButton")
            RealBtn.Size = UDim2.new(0, 100, 0, 30)
            RealBtn.Position = UDim2.new(1, -120, 0, (BaseHeight - 30) / 2)
            RealBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            RealBtn.Text = "Execute"
            RealBtn.TextColor3 = OSX_Lib.Theme.TextMain
            RealBtn.TextSize = 13
            RealBtn.Font = OSX_Lib.Theme.FontBold
            RealBtn.Parent = BtnFrame

            local RBCorner = Instance.new("UICorner")
            RBCorner.CornerRadius = UDim.new(0, 6)
            RBCorner.Parent = RealBtn
            local RBStroke = Instance.new("UIStroke")
            RBStroke.Color = OSX_Lib.Theme.BorderColor
            RBStroke.Transparency = 0.8
            RBStroke.Parent = RealBtn

            RealBtn.MouseEnter:Connect(function()
                TweenService:Create(RealBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            end)
            RealBtn.MouseLeave:Connect(function()
                TweenService:Create(RealBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)

            RealBtn.MouseButton1Click:Connect(function()
                TweenService:Create(RealBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 95, 0, 28), Position = UDim2.new(1, -117, 0, ((BaseHeight - 30) / 2) + 1)}):Play()
                task.wait(0.1)
                TweenService:Create(RealBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(1, -120, 0, (BaseHeight - 30) / 2)}):Play()
                Callback()
            end)

            return PanelElements
        end

        if not CurrentTab then Select() end
        return Elements
    end

    function OSX_Lib:AddTab(TabConfig)
        return AddTab(TabConfig)
    end

    return OSX_Lib
end

print("OSX UI Library v7 (Complete Edition): Loaded Successfully!")
return OSX_Lib
