local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme / Constants
local Theme = {
    MainBG = Color3.fromRGB(10, 10, 10),
    MainTransparency = 0.1, -- 0.9 opacity in CSS is 0.1 transparency in Roblox
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.9,
    Accent = Color3.fromRGB(255, 255, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(136, 136, 136),
    SideItemActiveBG = Color3.fromRGB(255, 255, 255), -- rgba(255, 255, 255, 0.08)
    SideItemActiveTransparency = 0.92,
    Font = Enum.Font.Roboto, -- Roblox's Inter equivalent
    FontBold = Enum.Font.RobotoCondensed,
}

-- Utility Functions
local function MakeDraggable(TopBar, Main)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil

    local function Update(Input)
        local Delta = Input.Position - DragStart
        local EndPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = EndPos}):Play()
    end

    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Main.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
end

function OSX_Lib:CreateWindow(Config)
    Config = Config or {}
    local TitleText = Config.Title or "OSX HUB"
    local SubtitleText = Config.Subtitle or "Status: Undetected"

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OSX_Lib"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui

    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.BackgroundColor3 = Theme.MainBG
    Main.BackgroundTransparency = Theme.MainTransparency
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.BorderColor
    MainStroke.Transparency = Theme.BorderTransparency
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    -- Top Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = Main

    -- Logo (White box, black text)
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Name = "LogoContainer"
    LogoContainer.Position = UDim2.new(0, 20, 0, 12)
    LogoContainer.Size = UDim2.new(0, 36, 0, 36)
    LogoContainer.BackgroundColor3 = Theme.Accent
    LogoContainer.Parent = Header

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoContainer

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "O"
    LogoText.TextColor3 = Color3.fromRGB(0, 0, 0)
    LogoText.TextSize = 20
    LogoText.Font = Theme.FontBold
    LogoText.Parent = LogoContainer

    -- Title/Subtitle Info
    local TitleInfo = Instance.new("Frame")
    TitleInfo.Name = "TitleInfo"
    TitleInfo.Position = UDim2.new(0, 70, 0, 12)
    TitleInfo.Size = UDim2.new(1, -80, 0, 36)
    TitleInfo.BackgroundTransparency = 1
    TitleInfo.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0.6, 0)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = Theme.TextMain
    Title.TextSize = 18
    Title.Font = Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleInfo

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Position = UDim2.new(0, 0, 0.6, 0)
    Subtitle.Size = UDim2.new(1, 0, 0.4, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = SubtitleText
    Subtitle.TextColor3 = Theme.TextDim
    Subtitle.TextSize = 12
    Subtitle.Font = Theme.Font
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleInfo

    -- Separation Line
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Position = UDim2.new(0, 0, 1, 0)
    Separator.Size = UDim2.new(1, 0, 0, 1)
    Separator.BackgroundColor3 = Theme.BorderColor
    Separator.BackgroundTransparency = 0.95
    Separator.BorderSizePixel = 0
    Separator.Parent = Header

    -- Body
    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Position = UDim2.new(0, 0, 0, 61)
    Body.Size = UDim2.new(1, 0, 1, -61)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.BorderColor
    Sidebar.BackgroundTransparency = 0.98
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Body

    local SidebarRightBorder = Instance.new("Frame")
    SidebarRightBorder.Name = "Border"
    SidebarRightBorder.Position = UDim2.new(1, 0, 0, 0)
    SidebarRightBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarRightBorder.BackgroundColor3 = Theme.BorderColor
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
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = SidebarList

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 15)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingRight = UDim.new(0, 10)
    SidebarPadding.Parent = SidebarList

    -- Container (Main Content)
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 160, 0, 0)
    Container.Size = UDim2.new(1, -160, 1, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Body

    local Tabs = {}
    local CurrentTab = nil

    function OSX_Lib:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        local TabTitle = TabConfig.Title or "Tab"
        local TabIcon = TabConfig.Icon or "home"

        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabTitle .. "_Btn"
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundTransparency = 1
        TabButton.BackgroundColor3 = Theme.SideItemActiveBG
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = SidebarList

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton

        local TabButtonActiveBorder = Instance.new("Frame")
        TabButtonActiveBorder.Name = "ActiveBorder"
        TabButtonActiveBorder.Size = UDim2.new(0, 3, 1, 0)
        TabButtonActiveBorder.BackgroundColor3 = Theme.Accent
        TabButtonActiveBorder.BackgroundTransparency = 1
        TabButtonActiveBorder.BorderSizePixel = 0
        TabButtonActiveBorder.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -10, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabTitle
        TabLabel.TextColor3 = Theme.TextMain
        TabLabel.TextSize = 14
        TabLabel.Font = Theme.Font
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.TextTransparency = 0.6
        TabLabel.Parent = TabButton

        -- Tab Content
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabTitle .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = Theme.Accent
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = Container

        local TabPageLayout = Instance.new("UIListLayout")
        TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabPageLayout.Padding = UDim.new(0, 10)
        TabPageLayout.Parent = TabPage

        local TabPagePadding = Instance.new("UIPadding")
        TabPagePadding.PaddingTop = UDim.new(0, 20)
        TabPagePadding.PaddingLeft = UDim.new(0, 20)
        TabPagePadding.PaddingRight = UDim.new(0, 20)
        TabPagePadding.Parent = TabPage

        -- Click Effect & Switching
        local function Select()
            if CurrentTab then
                CurrentTab.Page.Visible = false
                TweenService:Create(CurrentTab.Btn.ActiveBorder, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                TweenService:Create(CurrentTab.Label, TweenInfo.new(0.3), {TextTransparency = 0.6}):Play()
            end

            CurrentTab = {Btn = TabButton, Page = TabPage, Label = TabLabel}
            TabPage.Visible = true
            TweenService:Create(TabButton.ActiveBorder, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = Theme.SideItemActiveTransparency}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end

        TabButton.MouseButton1Click:Connect(Select)

        -- Element Generator
        local Elements = {}

        function Elements:AddButton(BtnConfig)
            BtnConfig = BtnConfig or {}
            local TitleStr = BtnConfig.Title or "Button"
            local Callback = BtnConfig.Callback or function() end

            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, 45)
            BtnFrame.BackgroundColor3 = Theme.BorderColor
            BtnFrame.BackgroundTransparency = 0.97
            BtnFrame.Parent = TabPage

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 8)
            BtnCorner.Parent = BtnFrame

            local RealBtn = Instance.new("TextButton")
            RealBtn.Size = UDim2.new(1, 0, 1, 0)
            RealBtn.BackgroundTransparency = 1
            RealBtn.Text = ""
            RealBtn.Parent = BtnFrame

            local BtnLabel = Instance.new("TextLabel")
            BtnLabel.Size = UDim2.new(1, -20, 1, 0)
            BtnLabel.Position = UDim2.new(0, 20, 0, 0)
            BtnLabel.BackgroundTransparency = 1
            BtnLabel.Text = TitleStr
            BtnLabel.TextColor3 = Theme.TextMain
            BtnLabel.TextSize = 14
            BtnLabel.Font = Theme.Font
            BtnLabel.TextXAlignment = Enum.TextXAlignment.Left
            BtnLabel.Parent = BtnFrame

            RealBtn.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.92}):Play()
            end)
            RealBtn.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.97}):Play()
            end)
            RealBtn.MouseButton1Down:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
            end)
            RealBtn.MouseButton1Up:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.92}):Play()
                Callback()
            end)

            return Elements
        end

        function Elements:AddToggle(TogConfig)
            TogConfig = TogConfig or {}
            local TitleStr = TogConfig.Title or "Toggle"
            local Default = TogConfig.Default or false
            local Callback = TogConfig.Callback or function() end
            local State = Default

            local TogFrame = Instance.new("Frame")
            TogFrame.Size = UDim2.new(1, 0, 0, 45)
            TogFrame.BackgroundColor3 = Theme.BorderColor
            TogFrame.BackgroundTransparency = 0.97
            TogFrame.Parent = TabPage

            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(0, 8)
            TogCorner.Parent = TogFrame

            local TogLabel = Instance.new("TextLabel")
            TogLabel.Size = UDim2.new(1, -60, 1, 0)
            TogLabel.Position = UDim2.new(0, 20, 0, 0)
            TogLabel.BackgroundTransparency = 1
            TogLabel.Text = TitleStr
            TogLabel.TextColor3 = Theme.TextMain
            TogLabel.TextSize = 14
            TogLabel.Font = Theme.Font
            TogLabel.TextXAlignment = Enum.TextXAlignment.Left
            TogLabel.Parent = TogFrame

            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(0, 36, 0, 20)
            ToggleBg.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleBg.BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(40, 40, 40)
            ToggleBg.Parent = TogFrame

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCorner.Parent = ToggleBg

            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size = UDim2.new(0, 14, 0, 14)
            ToggleDot.Position = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
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

            local function Toggle()
                State = not State
                local EndPos = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                local EndColor = State and Theme.Accent or Color3.fromRGB(40, 40, 40)
                local DotColor = State and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)

                TweenService:Create(ToggleDot, TweenInfo.new(0.25), {Position = EndPos, BackgroundColor3 = DotColor}):Play()
                TweenService:Create(ToggleBg, TweenInfo.new(0.25), {BackgroundColor3 = EndColor}):Play()
                
                Callback(State)
            end

            ClickArea.MouseButton1Click:Connect(Toggle)

            return Elements
        end

        function Elements:AddSlider(SliConfig)
            SliConfig = SliConfig or {}
            local TitleStr = SliConfig.Title or "Slider"
            local Default = SliConfig.Default or 50
            local Min = SliConfig.Min or 0
            local Max = SliConfig.Max or 100
            local Rounding = SliConfig.Rounding or 1
            local Callback = SliConfig.Callback or function() end
            local Value = Default

            local SliFrame = Instance.new("Frame")
            SliFrame.Size = UDim2.new(1, 0, 0, 55)
            SliFrame.BackgroundColor3 = Theme.BorderColor
            SliFrame.BackgroundTransparency = 0.97
            SliFrame.Parent = TabPage

            local SliCorner = Instance.new("UICorner")
            SliCorner.CornerRadius = UDim.new(0, 8)
            SliCorner.Parent = SliFrame

            local SliLabel = Instance.new("TextLabel")
            SliLabel.Size = UDim2.new(1, -20, 0, 25)
            SliLabel.Position = UDim2.new(0, 20, 0, 5)
            SliLabel.BackgroundTransparency = 1
            SliLabel.Text = TitleStr
            SliLabel.TextColor3 = Theme.TextMain
            SliLabel.TextSize = 13
            SliLabel.Font = Theme.Font
            SliLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliLabel.Parent = SliFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -70, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = Theme.TextDim
            ValueLabel.TextSize = 12
            ValueLabel.Font = Theme.Font
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliFrame

            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, -40, 0, 4)
            SliderBg.Position = UDim2.new(0, 20, 0, 40)
            SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SliderBg.Parent = SliFrame

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(1, 0)
            SliderCorner.Parent = SliderBg

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.Parent = SliderBg

            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill

            local SliderDot = Instance.new("Frame")
            SliderDot.Size = UDim2.new(0, 12, 0, 12)
            SliderDot.Position = UDim2.new(1, -6, 0.5, -6)
            SliderDot.BackgroundColor3 = Theme.Accent
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

            return Elements
        end

        function Elements:AddDropdown(DropConfig)
            DropConfig = DropConfig or {}
            local TitleStr = DropConfig.Title or "Dropdown"
            local Options = DropConfig.Options or {"Option 1", "Option 2"}
            local Default = DropConfig.Default or Options[1]
            local Callback = DropConfig.Callback or function() end
            local Selected = Default
            local Opened = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 45)
            DropFrame.BackgroundColor3 = Theme.BorderColor
            DropFrame.BackgroundTransparency = 0.97
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 8)
            DropCorner.Parent = DropFrame

            local DropLabel = Instance.new("TextLabel")
            DropLabel.Size = UDim2.new(1, -60, 0, 45)
            DropLabel.Position = UDim2.new(0, 20, 0, 0)
            DropLabel.BackgroundTransparency = 1
            DropLabel.Text = TitleStr
            DropLabel.TextColor3 = Theme.TextMain
            DropLabel.TextSize = 14
            DropLabel.Font = Theme.Font
            DropLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropLabel.Parent = DropFrame

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0, 100, 0, 45)
            SelectedLabel.Position = UDim2.new(1, -130, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = Selected
            SelectedLabel.TextColor3 = Theme.TextDim
            SelectedLabel.TextSize = 12
            SelectedLabel.Font = Theme.Font
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.Parent = DropFrame

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 0, 45)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "+"
            Arrow.TextColor3 = Theme.TextDim
            Arrow.TextSize = 18
            Arrow.Font = Theme.Font
            Arrow.Parent = DropFrame

            local DropList = Instance.new("Frame")
            DropList.Name = "DropList"
            DropList.Position = UDim2.new(0, 5, 0, 45)
            DropList.Size = UDim2.new(1, -10, 0, 0)
            DropList.BackgroundTransparency = 1
            DropList.Parent = DropFrame

            local DropLayout = Instance.new("UIListLayout")
            DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropLayout.Padding = UDim.new(0, 2)
            DropLayout.Parent = DropList

            local function Refresh()
                for _, v in pairs(DropList:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end

                for i, v in pairs(Options) do
                    local OptionBtn = Instance.new("TextButton")
                    OptionBtn.Size = UDim2.new(1, 0, 0, 35)
                    OptionBtn.BackgroundColor3 = Theme.BorderColor
                    OptionBtn.BackgroundTransparency = (v == Selected) and 0.9 or 0.98
                    OptionBtn.Text = v
                    OptionBtn.TextColor3 = (v == Selected) and Theme.TextMain or Theme.TextDim
                    OptionBtn.TextSize = 13
                    OptionBtn.Font = Theme.Font
                    OptionBtn.Parent = DropList

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 6)
                    OptCorner.Parent = OptionBtn

                    OptionBtn.MouseButton1Click:Connect(function()
                        Selected = v
                        SelectedLabel.Text = v
                        Opened = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 45)}):Play()
                        Arrow.Rotation = 0
                        Refresh()
                        Callback(v)
                    end)
                end
            end

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 0, 45)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.Parent = DropFrame

            ClickArea.MouseButton1Click:Connect(function()
                Opened = not Opened
                local TargetHeight = Opened and (45 + (#Options * 37) + 5) or 45
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Opened and 45 or 0}):Play()
                if Opened then Refresh() end
            end)

            return Elements
        end

        function Elements:AddInput(InputConfig)
            InputConfig = InputConfig or {}
            local TitleStr = InputConfig.Title or "Input"
            local Placeholder = InputConfig.Placeholder or "Type here..."
            local Callback = InputConfig.Callback or function() end

            local InpFrame = Instance.new("Frame")
            InpFrame.Size = UDim2.new(1, 0, 0, 45)
            InpFrame.BackgroundColor3 = Theme.BorderColor
            InpFrame.BackgroundTransparency = 0.97
            InpFrame.Parent = TabPage

            local InpCorner = Instance.new("UICorner")
            InpCorner.CornerRadius = UDim.new(0, 8)
            InpCorner.Parent = InpFrame

            local InpLabel = Instance.new("TextLabel")
            InpLabel.Size = UDim2.new(0.4, 0, 1, 0)
            InpLabel.Position = UDim2.new(0, 20, 0, 0)
            InpLabel.BackgroundTransparency = 1
            InpLabel.Text = TitleStr
            InpLabel.TextColor3 = Theme.TextMain
            InpLabel.TextSize = 14
            InpLabel.Font = Theme.Font
            InpLabel.TextXAlignment = Enum.TextXAlignment.Left
            InpLabel.Parent = InpFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.5, 0, 0.7, 0)
            TextBox.Position = UDim2.new(1, -10, 0.5, 0)
            TextBox.AnchorPoint = Vector2.new(1, 0.5)
            TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            TextBox.BackgroundTransparency = 0.5
            TextBox.BorderSizePixel = 0
            TextBox.Text = ""
            TextBox.PlaceholderText = Placeholder
            TextBox.TextColor3 = Theme.TextMain
            TextBox.PlaceholderColor3 = Theme.TextDim
            TextBox.TextSize = 13
            TextBox.Font = Theme.Font
            TextBox.TextXAlignment = Enum.TextXAlignment.Center
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = InpFrame

            local TextCorner = Instance.new("UICorner")
            TextCorner.CornerRadius = UDim.new(0, 6)
            TextCorner.Parent = TextBox

            TextBox.FocusLost:Connect(function(Enter)
                Callback(TextBox.Text, Enter)
            end)

            return Elements
        end

        function Elements:AddKeybind(KeyConfig)
            KeyConfig = KeyConfig or {}
            local TitleStr = KeyConfig.Title or "Keybind"
            local Default = KeyConfig.Default or Enum.KeyCode.RightControl
            local Callback = KeyConfig.Callback or function() end
            local Binding = false
            local CurrentKey = Default

            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, 0, 0, 45)
            KeyFrame.BackgroundColor3 = Theme.BorderColor
            KeyFrame.BackgroundTransparency = 0.97
            KeyFrame.Parent = TabPage

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 8)
            KeyCorner.Parent = KeyFrame

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Size = UDim2.new(1, -120, 1, 0)
            KeyLabel.Position = UDim2.new(0, 20, 0, 0)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Text = TitleStr
            KeyLabel.TextColor3 = Theme.TextMain
            KeyLabel.TextSize = 14
            KeyLabel.Font = Theme.Font
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyLabel.Parent = KeyFrame

            local KeyDisplay = Instance.new("TextLabel")
            KeyDisplay.Size = UDim2.new(0, 80, 0, 25)
            KeyDisplay.Position = UDim2.new(1, -90, 0.5, -12)
            KeyDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            KeyDisplay.Text = CurrentKey.Name
            KeyDisplay.TextColor3 = Theme.Accent
            KeyDisplay.TextSize = 12
            KeyDisplay.Font = Theme.Font
            KeyDisplay.Parent = KeyFrame

            local KeyDisplayCorner = Instance.new("UICorner")
            KeyDisplayCorner.CornerRadius = UDim.new(0, 6)
            KeyDisplayCorner.Parent = KeyDisplay

            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.Parent = KeyFrame

            ClickArea.MouseButton1Click:Connect(function()
                Binding = true
                KeyDisplay.Text = "..."
                KeyDisplay.TextColor3 = Theme.TextDim
            end)

            UserInputService.InputBegan:Connect(function(Input)
                if Binding and Input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = Input.KeyCode
                    KeyDisplay.Text = CurrentKey.Name
                    KeyDisplay.TextColor3 = Theme.Accent
                    Binding = false
                    Callback(CurrentKey)
                end
            end)

            return Elements
        end

        function Elements:AddLabel(Text)
            local LabFrame = Instance.new("Frame")
            LabFrame.Size = UDim2.new(1, 0, 0, 30)
            LabFrame.BackgroundTransparency = 1
            LabFrame.Parent = TabPage

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 20, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Theme.TextDim
            Label.TextSize = 13
            Label.Font = Theme.Font
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = LabFrame

            -- Auto resize height based on text
            Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
                LabFrame.Size = UDim2.new(1, 0, 0, Label.TextBounds.Y + 5)
            end)

            return Elements
        end

        -- Initial Selection for the first tab
        if not CurrentTab then
            Select()
        end

        return Elements
    end

    MakeDraggable(Header, Main)

    return OSX_Lib
end

return OSX_Lib
