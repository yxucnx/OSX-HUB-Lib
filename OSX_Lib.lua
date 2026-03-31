local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme / Constants
OSX_Lib.Theme = {
    MainBG = Color3.fromRGB(8, 8, 8),
    MainTransparency = 0.05,
    CardBG = Color3.fromRGB(15, 15, 15),
    CardTransparency = 0.4,
    Accent = Color3.fromRGB(255, 255, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(136, 136, 136),
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.92,
    SideItemActiveBG = Color3.fromRGB(255, 255, 255),
    SideItemActiveTransparency = 0.92,
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    CornerRadius = 15,
}

-- Icon Downloader
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
    local Target = IconMap[Name] or Name
    if string.find(Target, "rbxassetid://") or tonumber(Target) then
        return string.find(Target, "rbxassetid://") and Target or "rbxassetid://" .. Target
    end
    if string.find(Target, "http") then
        local customasset = getcustomasset or get_custom_asset
        local success, result = pcall(function()
            if not (writefile and customasset and isfile) then error("Not supported") end
            local SafeName = Name:gsub("%W", "")
            local FileName = "OSX_v4_" .. SafeName .. ".png"
            if not isfile(FileName) then
                local data = game:HttpGet(Target:split("?")[1])
                writefile(FileName, data)
            end
            return customasset(FileName)
        end)
        if success then return result end
    end
    return ""
end

-- Powerful Draggable System
local function MakeDraggable(Frame, Handle)
    Handle = Handle or Frame
    local Dragging = false
    local DragStart = nil
    local StartPos = nil

    Handle.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
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
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = false
        end
    end)
end

function OSX_Lib:CreateWindow(Config)
    Config = Config or {}
    local TitleText = Config.Title or "OSX HUB"
    local SubtitleText = Config.Subtitle or "discord.gg/osxhub"
    local MainLogoId = GetIcon(Config.WindowLogo or "info")
    local FloatLogoId = GetIcon(Config.FloatingLogo or MainLogoId)
    local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightControl

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OSX_Lib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

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

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = Main
    Header.Size = UDim2.new(1, 0, 0, 75)
    Header.BackgroundTransparency = 1

    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "LogoContainer"
    LogoContainer.Position = UDim2.new(0, 25, 0, 15)
    LogoContainer.Size = UDim2.new(0, 55, 0, 45)
    LogoContainer.BackgroundTransparency = 1
    LogoContainer.Parent = Header

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Size = UDim2.new(1, 0, 1, 0)
    LogoImage.BackgroundTransparency = 1
    LogoImage.Image = MainLogoId
    LogoImage.ScaleType = Enum.ScaleType.Fit
    LogoImage.Parent = LogoContainer

    local TitleInfo = Instance.new("Frame")
    TitleInfo.Name = "TitleInfo"
    TitleInfo.Position = UDim2.new(0, 95, 0, 15)
    TitleInfo.Size = UDim2.new(1, -150, 0, 45)
    TitleInfo.BackgroundTransparency = 1
    TitleInfo.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = OSX_Lib.Theme.TextMain
    Title.TextSize = 17
    Title.Font = OSX_Lib.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleInfo

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Position = UDim2.new(0, 0, 0.5, 5)
    Subtitle.Size = UDim2.new(1, 0, 0.5, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = SubtitleText
    Subtitle.TextColor3 = OSX_Lib.Theme.TextDim
    Subtitle.TextSize = 11
    Subtitle.Font = OSX_Lib.Theme.Font
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleInfo

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

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = OSX_Lib.Theme.TextDim
    CloseBtn.TextSize = 18
    CloseBtn.Font = OSX_Lib.Theme.FontBold
    CloseBtn.Parent = BtnContainer

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = OSX_Lib.Theme.TextDim
    MinimizeBtn.TextSize = 24
    MinimizeBtn.Font = OSX_Lib.Theme.FontBold
    MinimizeBtn.Parent = BtnContainer

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Position = UDim2.new(0, 0, 0, 76)
    Body.Size = UDim2.new(1, 0, 1, -76)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    Sidebar.BackgroundTransparency = 0.985
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarList = Instance.new("ScrollingFrame")
    SidebarList.Name = "SidebarList"
    SidebarList.Size = UDim2.new(1, 0, 1, 0)
    SidebarList.BackgroundTransparency = 1
    SidebarList.BorderSizePixel = 0
    SidebarList.ScrollBarThickness = 0
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

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 175, 0, 0)
    Container.Size = UDim2.new(1, -175, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Body

    local UI_Visible = true
    local FloatingGui = Instance.new("ScreenGui")
    FloatingGui.Name = "OSX_Floating"
    FloatingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    FloatingGui.Enabled = false
    FloatingGui.Parent = game:GetService("CoreGui")

    local FloatingFrame = Instance.new("Frame")
    FloatingFrame.Size = UDim2.new(0, 60, 0, 60)
    FloatingFrame.Position = UDim2.new(0, 50, 0, 200)
    FloatingFrame.BackgroundTransparency = 1
    FloatingFrame.Parent = FloatingGui

    local FloatingLogo = Instance.new("ImageLabel")
    FloatingLogo.Size = UDim2.new(1, 0, 1, 0)
    FloatingLogo.BackgroundTransparency = 1
    FloatingLogo.Image = FloatLogoId
    FloatingLogo.ScaleType = Enum.ScaleType.Fit
    FloatingLogo.Parent = FloatingFrame

    local function SetUIVisible(state)
        UI_Visible = state
        Main.Visible = state
        FloatingGui.Enabled = not state
    end

    MinimizeBtn.MouseButton1Click:Connect(function() SetUIVisible(false) end)

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
            if Clicking and (EndPos - DragStartPos).Magnitude < 10 then
                SetUIVisible(true)
            end
            Clicking = false
        end
    end)

    MakeDraggable(Main, Header)
    MakeDraggable(FloatingFrame, FloatingFrame)

    UserInputService.InputBegan:Connect(function(Input)
        if Input.KeyCode == ToggleKey then SetUIVisible(not UI_Visible) end
    end)

    local CurrentTab = nil

    function OSX_Lib:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        local TabTitle = TabConfig.Title or "Tab"
        local TabSub = TabConfig.SubDescription or "Information"
        local TabIconId = GetIcon(TabConfig.Icon or "info")

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 60)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = SidebarList

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -55, 0.4, 0)
        TabLabel.Position = UDim2.new(0, 50, 0.25, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabTitle
        TabLabel.TextColor3 = OSX_Lib.Theme.TextMain
        TabLabel.Font = OSX_Lib.Theme.FontBold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = Container

        local TabPageLayout = Instance.new("UIListLayout")
        TabPageLayout.Padding = UDim.new(0, 12)
        TabPageLayout.Parent = TabPage

        local function Select()
            if CurrentTab then CurrentTab.Page.Visible = false end
            CurrentTab = {Page = TabPage}
            TabPage.Visible = true
        end
        TabButton.MouseButton1Click:Connect(Select)

        local Elements = {}

        function Elements:AddPanel(PanelTitle)
            local PanelFrame = Instance.new("Frame")
            PanelFrame.Size = UDim2.new(1, 0, 0, 100)
            PanelFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            PanelFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            PanelFrame.Parent = TabPage
            Instance.new("UICorner", PanelFrame).CornerRadius = UDim.new(0, 15)
            
            local PanelLabel = Instance.new("TextLabel")
            PanelLabel.Text = PanelTitle or ""
            PanelLabel.Size = UDim2.new(1, -20, 0, 30)
            PanelLabel.Position = UDim2.new(0, 10, 0, 5)
            PanelLabel.TextColor3 = OSX_Lib.Theme.TextMain
            PanelLabel.BackgroundTransparency = 1
            PanelLabel.Parent = PanelFrame

            local PanelElements = {}
            function PanelElements:AddInfoLabel(L, V)
                local Info = Instance.new("TextLabel")
                Info.Text = L .. ": " .. V
                Info.Size = UDim2.new(1, -20, 0, 20)
                Info.TextColor3 = OSX_Lib.Theme.TextDim
                Info.BackgroundTransparency = 1
                Info.Parent = PanelFrame
                return PanelElements
            end
            return PanelElements
        end

        function Elements:AddToggle(TogConfig)
            local Tog = Instance.new("TextButton")
            Tog.Size = UDim2.new(1, 0, 0, 40)
            Tog.Text = TogConfig.Title or "Toggle"
            Tog.Parent = TabPage
            Tog.MouseButton1Click:Connect(function() TogConfig.Callback(true) end)
            return Elements
        end

        if not CurrentTab then Select() end
        return Elements
    end

    return OSX_Lib
end

print("OSX UI Library v2.1: Loaded Successfully!")
return OSX_Lib
