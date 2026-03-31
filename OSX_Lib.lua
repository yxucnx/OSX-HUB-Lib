local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

-- Icon Downloader Utility
local IconMap = {
    ["home"] = "http://www.roblox.com/asset/?id=10723343321",
    ["user"] = "http://www.roblox.com/asset/?id=11293988182",
    ["eye"] = "http://www.roblox.com/asset/?id=11295291410",
    ["settings"] = "http://www.roblox.com/asset/?id=11293971586",
    ["info"] = "http://www.roblox.com/asset/?id=10723415903",
    ["database"] = "http://www.roblox.com/asset/?id=11294101962",
    ["shield"] = "http://www.roblox.com/asset/?id=11293992200",
    ["lock"] = "http://www.roblox.com/asset/?id=11293990326"
}

local function GetIcon(Name)
    if not Name or Name == "" then return "" end
    Name = Name:lower()
    local Target = IconMap[Name] or Name
    
    if string.find(Target, "http") and not string.find(Target, "asset") then
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
    return Target
end

-- Robust Draggable System
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

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, OSX_Lib.Theme.CornerRadius)
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = OSX_Lib.Theme.BorderColor
    MainStroke.Transparency = OSX_Lib.Theme.BorderTransparency

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
    TitleInfo.Position = UDim2.new(0, 95, 0, 15)
    TitleInfo.Size = UDim2.new(1, -150, 0, 45)
    TitleInfo.BackgroundTransparency = 1
    TitleInfo.Parent = Header

    local Title = Instance.new("TextLabel", TitleInfo)
    Title.Size = UDim2.new(1, 0, 0.5, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = OSX_Lib.Theme.TextMain
    Title.TextSize = 17
    Title.Font = OSX_Lib.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Subtitle = Instance.new("TextLabel", TitleInfo)
    Subtitle.Position = UDim2.new(0, 0, 0.5, 5)
    Subtitle.Size = UDim2.new(1, 0, 0.5, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = SubtitleText
    Subtitle.TextColor3 = OSX_Lib.Theme.TextDim
    Subtitle.TextSize = 11
    Subtitle.Font = OSX_Lib.Theme.Font
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

    local BtnContainer = Instance.new("Frame", Header)
    BtnContainer.Position = UDim2.new(1, -100, 0, 25)
    BtnContainer.Size = UDim2.new(0, 80, 0, 30)
    BtnContainer.BackgroundTransparency = 1

    local BtnLayout = Instance.new("UIListLayout", BtnContainer)
    BtnLayout.FillDirection = Enum.FillDirection.Horizontal
    BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BtnLayout.Padding = UDim.new(0, 10)

    local CloseBtn = Instance.new("TextButton", BtnContainer)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = OSX_Lib.Theme.TextDim
    CloseBtn.Font = OSX_Lib.Theme.FontBold
    CloseBtn.LayoutOrder = 2
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MinimizeBtn = Instance.new("TextButton", BtnContainer)
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = OSX_Lib.Theme.TextDim
    MinimizeBtn.Font = OSX_Lib.Theme.FontBold
    MinimizeBtn.LayoutOrder = 1

    local Body = Instance.new("Frame", Main)
    Body.Name = "Body"
    Body.Position = UDim2.new(0, 0, 0, 76)
    Body.Size = UDim2.new(1, 0, 1, -76)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    Sidebar.BackgroundTransparency = 0.985
    Sidebar.BorderSizePixel = 0
    
    Instance.new("Frame", Sidebar).Name = "Line" -- Right border
    Sidebar.Line.Position = UDim2.new(1, 0, 0, 0)
    Sidebar.Line.Size = UDim2.new(0, 1, 1, 0)
    Sidebar.Line.BackgroundColor3 = OSX_Lib.Theme.BorderColor
    Sidebar.Line.BackgroundTransparency = 0.95

    local SidebarList = Instance.new("ScrollingFrame", Sidebar)
    SidebarList.Name = "SidebarList"
    SidebarList.Size = UDim2.new(1, 0, 1, 0)
    SidebarList.BackgroundTransparency = 1
    SidebarList.BorderSizePixel = 0
    SidebarList.ScrollBarThickness = 0

    Instance.new("UIListLayout", SidebarList).Padding = UDim.new(0, 8)
    Instance.new("UIPadding", SidebarList).PaddingLeft = UDim.new(0, 10)
    SidebarList.UIPadding.PaddingTop = UDim.new(0, 15)

    local Container = Instance.new("Frame", Body)
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 175, 0, 0)
    Container.Size = UDim2.new(1, -175, 1, 0)
    Container.BackgroundTransparency = 1

    local UI_Visible = true
    local FloatingGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    FloatingGui.Enabled = false
    
    local FloatingFrame = Instance.new("Frame", FloatingGui)
    FloatingFrame.Size = UDim2.new(0, 60, 0, 60)
    FloatingFrame.Position = UDim2.new(0, 50, 0, 200)
    FloatingFrame.BackgroundTransparency = 1
    
    local FloatingLogo = Instance.new("ImageLabel", FloatingFrame)
    FloatingLogo.Size = UDim2.new(1, 0, 1, 0)
    FloatingLogo.BackgroundTransparency = 1
    FloatingLogo.Image = FloatLogoId
    FloatingLogo.ScaleType = Enum.ScaleType.Fit

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
            if Clicking and (Vector2.new(Input.Position.X, Input.Position.Y) - DragStartPos).Magnitude < 10 then
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

        local TabButton = Instance.new("TextButton", SidebarList)
        TabButton.Size = UDim2.new(1, -10, 0, 60)
        TabButton.BackgroundTransparency = 1
        TabButton.BackgroundColor3 = OSX_Lib.Theme.SideItemActiveBG
        TabButton.Text = ""
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 12)

        local ActiveIndicator = Instance.new("Frame", TabButton)
        ActiveIndicator.Size = UDim2.new(0, 4, 0.4, 0)
        ActiveIndicator.Position = UDim2.new(0, -6, 0.3, 0)
        ActiveIndicator.BackgroundColor3 = OSX_Lib.Theme.Accent
        ActiveIndicator.BackgroundTransparency = 1
        Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(1, 0)

        local Icon = Instance.new("ImageLabel", TabButton)
        Icon.Position = UDim2.new(0, 15, 0.5, -12)
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.BackgroundTransparency = 1
        Icon.Image = TabIconId
        Icon.ImageTransparency = 0.6

        local TabLabel = Instance.new("TextLabel", TabButton)
        TabLabel.Size = UDim2.new(1, -55, 0.4, 0)
        TabLabel.Position = UDim2.new(0, 50, 0.25, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabTitle
        TabLabel.TextColor3 = OSX_Lib.Theme.TextMain
        TabLabel.Font = OSX_Lib.Theme.FontBold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.TextTransparency = 0.6

        local TabSubLabel = Instance.new("TextLabel", TabButton)
        TabSubLabel.Size = UDim2.new(1, -55, 0.3, 0)
        TabSubLabel.Position = UDim2.new(0, 50, 0.65, 0)
        TabSubLabel.BackgroundTransparency = 1
        TabSubLabel.Text = TabSub
        TabSubLabel.TextColor3 = OSX_Lib.Theme.TextDim
        TabSubLabel.TextSize = 11
        TabSubLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabSubLabel.TextTransparency = 0.6

        local TabPage = Instance.new("ScrollingFrame", Container)
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = OSX_Lib.Theme.Accent

        Instance.new("UIListLayout", TabPage).Padding = UDim.new(0, 12)
        Instance.new("UIPadding", TabPage).PaddingTop = UDim.new(0, 25)
        TabPage.UIPadding.PaddingLeft = UDim.new(0, 30)
        TabPage.UIPadding.PaddingRight = UDim.new(0, 30)

        local function Select()
            if CurrentTab then
                CurrentTab.Page.Visible = false
                TweenService:Create(CurrentTab.Btn.ActiveIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, 4, 0.4, 0)}):Play()
                TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(CurrentTab.Btn.Icon, TweenInfo.new(0.3), {ImageTransparency = 0.6}):Play()
                TweenService:Create(CurrentTab.Btn.TabLabel, TweenInfo.new(0.3), {TextTransparency = 0.6}):Play()
                TweenService:Create(CurrentTab.Btn.TabSubLabel, TweenInfo.new(0.3), {TextTransparency = 0.6}):Play()
            end
            CurrentTab = {Page = TabPage, Btn = {ActiveIndicator=ActiveIndicator, Icon=Icon, TabLabel=TabLabel, TabSubLabel=TabSubLabel}}
            TabPage.Visible = true
            TweenService:Create(ActiveIndicator, TweenInfo.new(0.3), {BackgroundTransparency = 0, Size = UDim2.new(0, 4, 0.7, 0)}):Play()
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = OSX_Lib.Theme.SideItemActiveTransparency}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            TweenService:Create(TabSubLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end
        TabButton.MouseButton1Click:Connect(Select)

        local Elements = {}

        function Elements:AddPanel(PanelTitle)
            local PanelFrame = Instance.new("Frame", TabPage)
            PanelFrame.Size = UDim2.new(1, 0, 0, 40)
            PanelFrame.BackgroundColor3 = OSX_Lib.Theme.CardBG
            PanelFrame.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            Instance.new("UICorner", PanelFrame).CornerRadius = UDim.new(0, 15)
            Instance.new("UIStroke", PanelFrame).Color = OSX_Lib.Theme.BorderColor
            PanelFrame.UIStroke.Transparency = OSX_Lib.Theme.BorderTransparency

            local PanelHeader = Instance.new("TextLabel", PanelFrame)
            PanelHeader.Text = PanelTitle or ""
            PanelHeader.Size = UDim2.new(1, 0, 0, 40)
            PanelHeader.Position = UDim2.new(0, 25, 0, 5)
            PanelHeader.TextColor3 = OSX_Lib.Theme.TextMain
            PanelHeader.Font = OSX_Lib.Theme.FontBold
            PanelHeader.BackgroundTransparency = 1
            PanelHeader.TextXAlignment = Enum.TextXAlignment.Left

            local PanelList = Instance.new("Frame", PanelFrame)
            PanelList.Position = UDim2.new(0, 0, 0, 50)
            PanelList.Size = UDim2.new(1, 0, 0, 0)
            PanelList.BackgroundTransparency = 1
            
            local PLay = Instance.new("UIListLayout", PanelList)
            PLay.SortOrder = Enum.SortOrder.LayoutOrder
            PLay.Padding = UDim.new(0, 5)
            
            Instance.new("UIPadding", PanelList).PaddingLeft = UDim.new(0, 25)
            PanelList.UIPadding.PaddingRight = UDim.new(0, 25)
            PanelList.UIPadding.PaddingBottom = UDim.new(0, 20)

            PLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PanelFrame.Size = UDim2.new(1, 0, 0, PLay.AbsoluteContentSize.Y + 70)
            end)

            local PanelElements = {}
            function PanelElements:AddInfoLabel(Label, Value)
                local InfoFrame = Instance.new("Frame", PanelList)
                InfoFrame.Size = UDim2.new(1, 0, 0, 35)
                InfoFrame.BackgroundTransparency = 1

                local L = Instance.new("TextLabel", InfoFrame)
                L.Size = UDim2.new(0.4, 0, 1, 0)
                L.Text = Label
                L.TextColor3 = OSX_Lib.Theme.TextDim
                L.BackgroundTransparency = 1
                L.TextXAlignment = Enum.TextXAlignment.Left

                local V = Instance.new("TextLabel", InfoFrame)
                V.Size = UDim2.new(0.6, 0, 1, 0)
                V.Position = UDim2.new(0.4, 0, 0, 0)
                V.Text = Value
                V.TextColor3 = OSX_Lib.Theme.TextMain
                V.Font = OSX_Lib.Theme.FontBold
                V.BackgroundTransparency = 1
                V.TextXAlignment = Enum.TextXAlignment.Left

                local Div = Instance.new("Frame", InfoFrame)
                Div.Size = UDim2.new(1, 0, 0, 1)
                Div.Position = UDim2.new(0, 0, 1, 0)
                Div.BackgroundColor3 = OSX_Lib.Theme.BorderColor
                Div.BackgroundTransparency = 0.95
                Div.BorderSizePixel = 0
                return PanelElements
            end
            
            function PanelElements:AddWideButton(BConfig)
                local BF = Instance.new("Frame", PanelList)
                BF.Size = UDim2.new(1, 0, 0, 45)
                BF.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                BF.BackgroundTransparency = 0.5
                Instance.new("UICorner", BF).CornerRadius = UDim.new(0, 12)
                
                local RB = Instance.new("TextButton", BF)
                RB.Size = UDim2.new(1, 0, 1, 0)
                RB.BackgroundTransparency = 1
                RB.Text = BConfig.Title or "Button"
                RB.TextColor3 = OSX_Lib.Theme.TextMain
                RB.Font = OSX_Lib.Theme.FontBold
                RB.MouseButton1Click:Connect(BConfig.Callback or function() end)
                return PanelElements
            end
            return PanelElements
        end

        function Elements:AddToggle(TConfig)
            local TF = Instance.new("Frame", TabPage)
            TF.Size = UDim2.new(1, 0, 0, 50)
            TF.BackgroundColor3 = OSX_Lib.Theme.CardBG
            TF.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            Instance.new("UICorner", TF).CornerRadius = UDim.new(0, 12)
            
            local L = Instance.new("TextLabel", TF)
            L.Size = UDim2.new(1, -60, 1, 0)
            L.Position = UDim2.new(0, 20, 0, 0)
            L.Text = TConfig.Title or "Toggle"
            L.TextColor3 = OSX_Lib.Theme.TextMain
            L.Font = OSX_Lib.Theme.FontBold
            L.BackgroundTransparency = 1
            L.TextXAlignment = Enum.TextXAlignment.Left

            local State = TConfig.Default or false
            local TB = Instance.new("Frame", TF)
            TB.Size = UDim2.new(0, 42, 0, 22)
            TB.Position = UDim2.new(1, -60, 0.5, -11)
            TB.BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", TB).CornerRadius = UDim.new(1, 0)

            local TD = Instance.new("Frame", TB)
            TD.Size = UDim2.new(0, 16, 0, 16)
            TD.Position = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            TD.BackgroundColor3 = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", TD).CornerRadius = UDim.new(1, 0)

            Instance.new("TextButton", TF).Size = UDim2.new(1, 0, 1, 0)
            TF.TextButton.BackgroundTransparency = 1
            TF.TextButton.Text = ""
            TF.TextButton.MouseButton1Click:Connect(function()
                State = not State
                TweenService:Create(TB, TweenInfo.new(0.2), {BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(TD, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}):Play()
                if TConfig.Callback then TConfig.Callback(State) end
            end)
            return Elements
        end

        function Elements:AddSlider(SConfig)
            local SF = Instance.new("Frame", TabPage)
            SF.Size = UDim2.new(1, 0, 0, 65)
            SF.BackgroundColor3 = OSX_Lib.Theme.CardBG
            SF.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
            Instance.new("UICorner", SF).CornerRadius = UDim.new(0, 12)

            local L = Instance.new("TextLabel", SF)
            L.Text = SConfig.Title or "Slider"
            L.Size = UDim2.new(1, -20, 0, 25)
            L.Position = UDim2.new(0, 20, 0, 10)
            L.TextColor3 = OSX_Lib.Theme.TextMain
            L.Font = OSX_Lib.Theme.FontBold
            L.BackgroundTransparency = 1
            L.TextXAlignment = Enum.TextXAlignment.Left

            local SB = Instance.new("Frame", SF)
            SB.Size = UDim2.new(1, -40, 0, 5)
            SB.Position = UDim2.new(0, 20, 0, 48)
            SB.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Instance.new("UICorner", SB).CornerRadius = UDim.new(1, 0)

            local SFill = Instance.new("Frame", SB)
            SFill.Size = UDim2.new((SConfig.Default - SConfig.Min)/(SConfig.Max - SConfig.Min), 0, 1, 0)
            SFill.BackgroundColor3 = OSX_Lib.Theme.Accent
            Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)

            local Value = SConfig.Default
            local function Move(Input)
                local P = math.clamp((Input.Position.X - SB.AbsolutePosition.X) / SB.AbsoluteSize.X, 0, 1)
                Value = math.floor(SConfig.Min + (SConfig.Max - SConfig.Min) * P)
                SFill.Size = UDim2.new(P, 0, 1, 0)
                if SConfig.Callback then SConfig.Callback(Value) end
            end

            local Dragging = false
            SB.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    Move(Input)
                end
            end)
            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    Move(Input)
                end
            end)
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
            return Elements
        end

        if not CurrentTab then Select() end
        return Elements
    end

    return OSX_Lib
end

print("OSX UI Library v2.2 [Premium Restore]: Loaded Successfully!")
return OSX_Lib
