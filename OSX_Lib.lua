local OSX_Lib = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme / Constants (Stealth Monochrome Redesign)
OSX_Lib.Version = "4.0.41"
OSX_Lib.UpdateLog = {
    ["4.0.41"] = "Fixed washed-out background issue in Update Popup",
    ["4.0.40"] = "Improved Update Popup UI (Header spacing & Removed Overlay)",
    ["4.0.39"] = "Added Update/Changelog Popup System",
    ["4.0.38"] = "Updated Notification Icons (Fixed Warning/Error visibility)",
    ["4.0.37"] = "Fixed Single Dropdown Description Clipping & Component Height consistency",
    ["4.0.36"] = "Removed Window Resize Button as requested",
    ["4.0.35"] = "Fixed Multi-Dropdown selection logic & Description clipping",
    ["4.0.34"] = "Initial Stealth Monochrome Redesign & Description Support"
}

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

-- Backend State
OSX_Lib.Flags = {}
OSX_Lib.Signals = {}
OSX_Lib.Connections = {}
OSX_Lib.Settings = {
    AutoSave = true
}

local function GenerateRandomName(Length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = ""
    for i = 1, Length or 12 do
        local rand = math.random(1, #chars)
        res = res .. string.sub(chars, rand, rand)
    end
    return res
end

-- Icon Mapping & Downloader (Lucide & URLs)
local IconMap = {
    ["home"] = "https://img.icons8.com/ios-filled/50/ffffff/home.png",
    ["user"] = "https://img.icons8.com/ios-filled/50/ffffff/user.png",
    ["eye"] = "https://img.icons8.com/ios-filled/50/ffffff/visible.png",
    ["settings"] = "https://img.icons8.com/ios-filled/50/ffffff/settings.png",
    ["info"] = "https://img.icons8.com/ios-filled/50/ffffff/info.png",
    ["database"] = "https://img.icons8.com/ios-filled/50/ffffff/database.png",
    ["shield"] = "https://img.icons8.com/ios-filled/50/ffffff/shield.png",
    ["lock"] = "https://img.icons8.com/ios-filled/50/ffffff/lock.png",
    
    -- Added & Verified Icons (v4+)
    ["sword"] = "https://img.icons8.com/ios-filled/50/ffffff/sword.png",
    ["target"] = "https://img.icons8.com/ios-filled/50/ffffff/target.png",
    ["crosshair"] = "https://img.icons8.com/ios-filled/50/ffffff/plus.png", -- Alternative: plus
    ["map"] = "https://img.icons8.com/ios-filled/50/ffffff/map-marker.png", -- Fixed name
    ["terminal"] = "https://img.icons8.com/ios-filled/50/ffffff/console.png", -- Fixed name
    ["shopping-cart"] = "https://img.icons8.com/ios-filled/50/ffffff/shopping-cart.png",
    ["zap"] = "https://img.icons8.com/ios-filled/50/ffffff/flash-on.png", -- Fixed name
    ["fire"] = "https://img.icons8.com/ios-filled/50/ffffff/fire-element.png", -- Fixed name
    ["star"] = "https://img.icons8.com/ios-filled/50/ffffff/star.png",
    ["bell"] = "https://img.icons8.com/ios-filled/50/ffffff/appointment-reminders.png", -- Fixed name
    ["mouse"] = "https://img.icons8.com/ios-filled/50/ffffff/mouse.png",
    ["monitor"] = "https://img.icons8.com/ios-filled/50/ffffff/monitor.png", -- Fixed name
    ["activity"] = "https://img.icons8.com/ios-filled/50/ffffff/pulse.png", -- Fixed name
    ["cloud"] = "https://img.icons8.com/ios-filled/50/ffffff/cloud.png",
    ["list"] = "https://img.icons8.com/ios-filled/50/ffffff/list.png",
    ["component"] = "https://img.icons8.com/ios-filled/50/ffffff/grid.png" -- Fixed name
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

-- Robust Parenting Helper
local function GetGuiParent()
    local success, coregui = pcall(function() return game:GetService("CoreGui") end)
    if success and coregui then return coregui end
    
    local success2, hui = pcall(function() return (gethui and gethui()) or nil end)
    if success2 and hui then return hui end
    
    local success3, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if success3 and pg then return pg end
    
    return nil
end

-- Color Utilities
local function ColorToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255), 
        math.floor(color.G * 255), 
        math.floor(color.B * 255)
    )
end

local function HexToColor(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1, 2)), 
        tonumber("0x" .. hex:sub(3, 4)), 
        tonumber("0x" .. hex:sub(5, 6))
    )
end

-- Global Notification System
local ActiveNotifications = {}
local TypeColors = {
    ["Success"] = Color3.fromRGB(0, 255, 127),
    ["Error"] = Color3.fromRGB(255, 69, 58),
    ["Warning"] = Color3.fromRGB(255, 214, 10),
    ["Info"] = Color3.fromRGB(10, 132, 255)
}
local TypeIcons = {
    ["Success"] = "rbxassetid://10733669112", -- Check Circle
    ["Error"] = "rbxassetid://10733682423",   -- Alert Circle (X)
    ["Warning"] = "rbxassetid://10733683802", -- Alert Triangle
    ["Info"] = "rbxassetid://10733681423"    -- Info Circle
}

local NotifyContainer = nil
function OSX_Lib:Notify(Config)
    Config = Config or {}
    local TitleText = Config.Title or "OSX HUB"
    local ContentText = Config.Content or "Notification"
    local Type = Config.Type or "Info"
    local Duration = Config.Duration or 3
    
    if not NotifyContainer then
        NotifyContainer = Instance.new("ScreenGui")
        NotifyContainer.Name = "OSX_Notifications"
        NotifyContainer.Parent = GetGuiParent()
        
        local Layout = Instance.new("UIListLayout")
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        Layout.Padding = UDim.new(0, 10)
        NotifyContainer.DisplayOrder = 100
    end

    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 300, 0, 75)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notif.BackgroundTransparency = 0.2
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    Notif.Parent = NotifyContainer
    
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 12)
    local Stroke = Instance.new("UIStroke", Notif)
    Stroke.Color = TypeColors[Type]
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1.5

    local Icon = Instance.new("ImageLabel", Notif)
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 15, 0, 15)
    Icon.BackgroundTransparency = 1
    Icon.Image = TypeIcons[Type] or TypeIcons["Info"]
    Icon.ImageColor3 = TypeColors[Type]
    Icon.ScaleType = Enum.ScaleType.Fit

    local Title = Instance.new("TextLabel", Notif)
    Title.Size = UDim2.new(1, -60, 0, 24)
    Title.Position = UDim2.new(0, 50, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = TypeColors[Type]
    Title.TextSize = 14
    Title.Font = OSX_Lib.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Content = Instance.new("TextLabel", Notif)
    Content.Size = UDim2.new(1, -30, 0, 30)
    Content.Position = UDim2.new(0, 15, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Text = ContentText
    Content.TextColor3 = OSX_Lib.Theme.TextDim
    Content.TextSize = 12
    Content.Font = OSX_Lib.Theme.Font
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextWrapped = true

    -- STACKING LOGIC
    local function UpdateStack()
        for i, v in ipairs(ActiveNotifications) do
            TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, -315, 1, - (i * 85) - 15)
            }):Play()
        end
    end

    table.insert(ActiveNotifications, 1, Notif)
    Notif.Position = UDim2.new(1, 300, 1, -90)
    UpdateStack()

    task.delay(Duration, function()
        TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 300, Notif.Position.Y.Scale, Notif.Position.Y.Offset)}):Play()
        task.wait(0.5)
        for i, v in ipairs(ActiveNotifications) do
            if v == Notif then
                table.remove(ActiveNotifications, i)
                break
            end
        end
        Notif:Destroy()
        UpdateStack()
    end)
end

-- Config System
local HttpService = game:GetService("HttpService")
local ConfigFolder = "OSX_RESOURCES"
local lastSave = 0
local saveDebounce = 0.5 -- Seconds

function OSX_Lib:SaveConfig(Name)
    Name = Name or "Default"
    OSX_Lib.LastConfigName = Name
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if not isfolder(ConfigFolder .. "/Configs") then makefolder(ConfigFolder .. "/Configs") end
    
    local Data = HttpService:JSONEncode(OSX_Lib.Flags)
    writefile(ConfigFolder .. "/Configs/" .. Name .. ".json", Data)
end

function OSX_Lib:AttemptAutoSave()
    if tick() - lastSave < saveDebounce then return end
    lastSave = tick()
    task.delay(saveDebounce, function()
        if tick() - lastSave >= saveDebounce then
            OSX_Lib:SaveConfig(OSX_Lib.LastConfigName or "Default")
        end
    end)
end

function OSX_Lib:LoadConfig(Name)
    Name = Name or "Default"
    OSX_Lib.LastConfigName = Name
    local Path = ConfigFolder .. "/Configs/" .. Name .. ".json"
    if isfile(Path) then
        local Data = HttpService:JSONDecode(readfile(Path))
        for k, v in pairs(Data) do
            OSX_Lib.Flags[k] = v
        end
        OSX_Lib:Notify({Title = "Config", Content = "Loaded: " .. Name, Type = "Success"})
    end
end

function OSX_Lib:SafeConnect(Signal, Callback)
    local Connection = Signal:Connect(Callback)
    table.insert(OSX_Lib.Connections, Connection)
    return Connection
end

function OSX_Lib:DisconnectAll()
    for _, conn in ipairs(OSX_Lib.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    OSX_Lib.Connections = {}
end

function OSX_Lib:Emit(Name, ...)
    if OSX_Lib.Signals[Name] then
        for _, cb in ipairs(OSX_Lib.Signals[Name]) do
            pcall(cb, ...)
        end
    end
end

function OSX_Lib:On(Name, Callback)
    OSX_Lib.Signals[Name] = OSX_Lib.Signals[Name] or {}
    table.insert(OSX_Lib.Signals[Name], Callback)
end

function OSX_Lib:SafeCallback(cb, ...)
    if not cb then return end
    local success, err = pcall(cb, ...)
    if not success then
        OSX_Lib:Notify({Title = "Callback Error", Content = "Check console for details", Type = "Error"})
        warn("OSX Lib Callback Error: " .. tostring(err))
    end
    
    if OSX_Lib.Settings.AutoSave then
        OSX_Lib:AttemptAutoSave()
    end
end

-- Global Tooltip System
local TooltipGui = nil
local TooltipFrame = nil
local TooltipLabel = nil

local function CreateTooltip()
    if TooltipGui then return end
    TooltipGui = Instance.new("ScreenGui")
    TooltipGui.Name = "OSX_Tooltips"
    TooltipGui.DisplayOrder = 999
    TooltipGui.Parent = GetGuiParent()

    TooltipFrame = Instance.new("Frame", TooltipGui)
    TooltipFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 1000
    Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", TooltipFrame)
    Stroke.Color = OSX_Lib.Theme.Accent
    Stroke.Transparency = 0.8

    TooltipLabel = Instance.new("TextLabel", TooltipFrame)
    TooltipLabel.Size = UDim2.new(1, -10, 1, -10)
    TooltipLabel.Position = UDim2.new(0, 5, 0, 5)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.TextColor3 = OSX_Lib.Theme.TextMain
    TooltipLabel.TextSize = 12
    TooltipLabel.Font = OSX_Lib.Theme.Font
    TooltipLabel.TextXAlignment = Enum.TextXAlignment.Center

    RunService.RenderStepped:Connect(function()
        if TooltipFrame.Visible then
            local MousePos = UserInputService:GetMouseLocation()
            TooltipFrame.Position = UDim2.new(0, MousePos.X + 15, 0, MousePos.Y + 15)
        end
    end)
end

function OSX_Lib:AddTooltip(Object, Text)
    if not Text or Text == "" then return end
    CreateTooltip()
    
    Object.MouseEnter:Connect(function()
        TooltipLabel.Text = Text
        local Size = game:GetService("TextService"):GetTextSize(Text, 12, OSX_Lib.Theme.Font, Vector2.new(300, 100))
        TooltipFrame.Size = UDim2.new(0, Size.X + 20, 0, Size.Y + 15)
        TooltipFrame.Visible = true
    end)
    
    Object.MouseLeave:Connect(function()
        TooltipFrame.Visible = false
    end)
end

-- Custom Scrollbar System
function OSX_Lib:ApplyCustomScroll(Scroller)
    Scroller.ScrollBarThickness = 0
    
    local ScrollTrack = Instance.new("Frame", Scroller.Parent)
    ScrollTrack.Name = "ScrollTrack"
    ScrollTrack.Size = UDim2.new(0, 4, 1, -20)
    ScrollTrack.Position = UDim2.new(1, -7, 0, 10)
    ScrollTrack.BackgroundTransparency = 1
    ScrollTrack.ZIndex = 10
    
    local Thumb = Instance.new("Frame", ScrollTrack)
    Thumb.Size = UDim2.new(1, 0, 0.2, 0)
    Thumb.BackgroundColor3 = OSX_Lib.Theme.TextDim
    Thumb.BackgroundTransparency = 0.7
    Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
    
    local function UpdateThumb()
        local CanvasSize = Scroller.AbsoluteCanvasSize.Y
        local WindowSize = Scroller.AbsoluteWindowSize.Y
        if CanvasSize <= WindowSize then
            Thumb.Visible = false
            return
        end
        Thumb.Visible = true
        local SizePercent = WindowSize / CanvasSize
        local PosPercent = math.clamp(Scroller.CanvasPosition.Y / (CanvasSize - WindowSize), 0, 1)
        
        Thumb.Size = UDim2.new(1, 0, SizePercent, 0)
        Thumb.Position = UDim2.new(0, 0, PosPercent * (1 - SizePercent), 0)
    end
    
    Scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateThumb)
    Scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(UpdateThumb)
    Scroller:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(UpdateThumb)
    
    UpdateThumb()
    
    -- Fade Logic
    local lastScroll = tick()
    Scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        lastScroll = tick()
        TweenService:Create(Thumb, TweenInfo.new(0.3), {BackgroundTransparency = 0.4}):Play()
    end)
    
    task.spawn(function()
        while Scroller.Parent do
            if tick() - lastScroll > 1 then
                TweenService:Create(Thumb, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
            end
            task.wait(0.5)
        end
    end)
end

-- ==========================================
-- INTERNAL UI ENGINE (Stealth Monochrome)
-- ==========================================

function OSX_Lib:Internal_AddButton(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Button"
    local Description = Config.Description or ""
    local Callback = Config.Callback or function() end

    local btn = Instance.new("TextButton")
    btn.Name = Title .. "_Btn"
    btn.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    btn.BackgroundColor3 = OSX_Lib.Theme.CardBG
    btn.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = Parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", btn)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Label = Instance.new("TextLabel", btn)
    Label.Size = UDim2.new(1, -20, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", btn)
        Desc.Size = UDim2.new(1, -20, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = OSX_Lib.Theme.CardTransparency}):Play()
    end)
    btn.MouseButton1Click:Connect(Callback)
    return btn
end

function OSX_Lib:Internal_AddToggle(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Toggle"
    local Description = Config.Description or ""
    local Default = Config.Default or false
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Title
    local State = Default

    local tog = Instance.new("TextButton")
    tog.Name = Title .. "_Tog"
    tog.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    tog.BackgroundColor3 = OSX_Lib.Theme.CardBG
    tog.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    tog.BorderSizePixel = 0
    tog.Text = ""
    tog.AutoButtonColor = false
    tog.Parent = Parent

    Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", tog)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Label = Instance.new("TextLabel", tog)
    Label.Size = UDim2.new(1, -60, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", tog)
        Desc.Size = UDim2.new(1, -60, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local Switch = Instance.new("Frame", tog)
    Switch.Size = UDim2.new(0, 36, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)
    Switch.BorderSizePixel = 0
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame", Switch)
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = State and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
    Circle.BackgroundColor3 = State and OSX_Lib.Theme.MainBG or Color3.fromRGB(150, 150, 150)
    Circle.BorderSizePixel = 0
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local function Update()
        TweenService:Create(Switch, TweenInfo.new(0.3), {BackgroundColor3 = State and OSX_Lib.Theme.Accent or Color3.fromRGB(40, 40, 40)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.3), {
            Position = State and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = State and OSX_Lib.Theme.MainBG or Color3.fromRGB(150, 150, 150)
        }):Play()
        
        if Flag and Flag ~= "" then
            OSX_Lib.Flags[Flag] = State
        end
        OSX_Lib:SafeCallback(Callback, State)
        OSX_Lib:Emit("ToggleChanged", Flag, State)
    end

    tog.MouseButton1Click:Connect(function()
        State = not State
        Update()
    end)

    Update()
    
    if Config.Tooltip then
        OSX_Lib:AddTooltip(tog, Config.Tooltip)
    end
    
    return tog
end

function OSX_Lib:Internal_AddSlider(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Slider"
    local Description = Config.Description or ""
    local Min = Config.Min or 0
    local Max = Config.Max or 100
    local Default = Config.Default or Min
    local Rounding = Config.Rounding or 0
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Title
    local Value = Default

    local sli = Instance.new("Frame")
    sli.Name = Title .. "_Sli"
    sli.Size = UDim2.new(1, 0, 0, Description ~= "" and 80 or 65)
    sli.BackgroundColor3 = OSX_Lib.Theme.CardBG
    sli.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    sli.Parent = Parent

    Instance.new("UICorner", sli).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", sli)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Label = Instance.new("TextLabel", sli)
    Label.Size = UDim2.new(1, -20, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", sli)
        Desc.Size = UDim2.new(1, -20, 0, 16)
        Desc.Position = UDim2.new(0, 15, 0, 28)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local ValLabel = Instance.new("TextLabel", sli)
    ValLabel.Size = UDim2.new(0, 50, 0, 30)
    ValLabel.Position = UDim2.new(1, -65, 0, 5)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(Value)
    ValLabel.TextColor3 = OSX_Lib.Theme.Accent
    ValLabel.TextSize = 13
    ValLabel.Font = OSX_Lib.Theme.FontBold
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBG = Instance.new("Frame", sli)
    SliderBG.Size = UDim2.new(1, -30, 0, 6)
    SliderBG.Position = UDim2.new(0, 15, 0, Description ~= "" and 57 or 42)
    SliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBG.BorderSizePixel = 0
    Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", SliderBG)
    Fill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
    Fill.BackgroundColor3 = OSX_Lib.Theme.Accent
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local function Move(Input)
        local Pos = math.clamp((Input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        Value = (Rounding == 0) and math.floor(Min + (Max - Min) * Pos) or tonumber(string.format("%." .. Rounding .. "f", Min + (Max - Min) * Pos))
        Fill.Size = UDim2.new(Pos, 0, 1, 0)
        ValLabel.Text = tostring(Value)
        
        if Flag and Flag ~= "" then
            OSX_Lib.Flags[Flag] = Value
        end
        OSX_Lib:SafeCallback(Callback, Value)
    end

    local Dragging = false
    sli.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Move(Input)
        end
    end)
    sli.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement) then
            Move(Input)
        end
    end)

    if Flag and Flag ~= "" then
        OSX_Lib.Flags[Flag] = Value
    end
    OSX_Lib:SafeCallback(Callback, Value)
    
    if Config.Tooltip then
        OSX_Lib:AddTooltip(sli, Config.Tooltip)
    end
    
    return sli
end

function OSX_Lib:Internal_AddInput(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Input"
    local Description = Config.Description or ""
    local Default = Config.Default or ""
    local Callback = Config.Callback or function() end

    local inp = Instance.new("Frame")
    inp.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    inp.BackgroundColor3 = OSX_Lib.Theme.CardBG
    inp.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    inp.Parent = Parent

    Instance.new("UICorner", inp).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", inp)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Label = Instance.new("TextLabel", inp)
    Label.Size = UDim2.new(0.4, 0, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", inp)
        Desc.Size = UDim2.new(0.4, 0, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local Box = Instance.new("TextBox", inp)
    Box.Size = UDim2.new(0.5, 0, 0, 26)
    Box.Position = UDim2.new(0.5, -5, 0.5, -13)
    Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Box.BorderSizePixel = 0
    Box.Text = Default
    Box.TextColor3 = OSX_Lib.Theme.TextMain
    Box.PlaceholderText = "Type here..."
    Box.Font = OSX_Lib.Theme.Font
    Box.TextSize = 12
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)

    Box.FocusLost:Connect(function(Enter)
        Callback(Box.Text)
    end)

    Callback(Default)
    
    if Config.Tooltip then
        OSX_Lib:AddTooltip(inp, Config.Tooltip)
    end
    
    return inp
end

function OSX_Lib:Internal_AddDropdown(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Dropdown"
    local Description = Config.Description or ""
    local Values = Config.Values or {}
    local Default = Config.Default or 1
    local Callback = Config.Callback or function() end
    local Open = false

    local drop = Instance.new("Frame")
    drop.Name = Title .. "_Drop"
    drop.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    drop.BackgroundColor3 = OSX_Lib.Theme.CardBG
    drop.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    drop.ClipsDescendants = true
    drop.Parent = Parent

    Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", drop)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Header = Instance.new("TextButton", drop)
    Header.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""

    local Label = Instance.new("TextLabel", Header)
    Label.Size = UDim2.new(1, -50, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    
    if Description ~= "" then
        local Desc = Instance.new("TextLabel", Header)
        Desc.Size = UDim2.new(1, -50, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end
    Label.Text = Title .. " (" .. (tonumber(Default) and (Values[Default] or Default) or Default) .. ")"
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Arrow = Instance.new("ImageLabel", Header)
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -30, 0.5, -8)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://10723415903" -- Down arrow icon
    Arrow.Rotation = 0

    local Content = Instance.new("Frame", drop)
    Content.Position = UDim2.new(0, 0, 0, Description ~= "" and 60 or 42)
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1

    local SearchBox = Instance.new("TextBox", Content)
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.new(0, 10, 0, 5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SearchBox.PlaceholderText = "Search..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = OSX_Lib.Theme.TextMain
    SearchBox.Font = OSX_Lib.Theme.Font
    SearchBox.TextSize = 12
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    local SearchStroke = Instance.new("UIStroke", SearchBox)
    SearchStroke.Color = OSX_Lib.Theme.Accent
    SearchStroke.Transparency = 0.8

    local List = Instance.new("Frame", Content)
    List.Position = UDim2.new(0, 10, 0, 40)
    List.Size = UDim2.new(1, -20, 0, 0)
    List.BackgroundTransparency = 1

    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 5)

    local function CreateItems(Filter)
        for _, v in ipairs(List:GetChildren()) do
            if v:IsA("TextButton") then v:Destroy() end
        end
        
        local Count = 0
        for i, v in ipairs(Values) do
            if not Filter or Filter == "" or string.find(tostring(v):lower(), Filter:lower()) then
                Count = Count + 1
                local Item = Instance.new("TextButton", List)
                Item.Size = UDim2.new(1, 0, 0, 25)
                Item.BackgroundTransparency = 1
                Item.Text = tostring(v)
                Item.TextColor3 = OSX_Lib.Theme.TextDim
                Item.Font = OSX_Lib.Theme.Font
                Item.TextSize = 13

                Item.MouseButton1Click:Connect(function()
                    Label.Text = Title .. " (" .. tostring(v) .. ")"
                    Callback(v)
                    Open = false
                    TweenService:Create(drop, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)}):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                end)
            end
        end
        List.Size = UDim2.new(1, -20, 0, Count * 30)
        Content.Size = UDim2.new(1, 0, 0, 40 + List.Size.Y.Offset + 10)
        if Open then
            TweenService:Create(drop, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, (Description ~= "" and 60 or 42) + Content.Size.Y.Offset)}):Play()
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        CreateItems(SearchBox.Text)
    end)

    Header.MouseButton1Click:Connect(function()
        Open = not Open
        if Open then CreateItems("") end
        TweenService:Create(drop, TweenInfo.new(0.3), {Size = Open and UDim2.new(1, 0, 0, (Description ~= "" and 60 or 42) + Content.Size.Y.Offset) or UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0}):Play()
    end)

    Callback(tonumber(Default) and (Values[Default] or Default) or Default)
    return drop
end

function OSX_Lib:Internal_AddMultiDropdown(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Multi-Dropdown"
    local Description = Config.Description or ""
    local Values = Config.Values or {}
    local Default = Config.Default or {}
    local Callback = Config.Callback or function() end
    local Open = false
    local Selected = {}
    
    for _, v in ipairs(Default) do Selected[v] = true end

    local drop = Instance.new("Frame")
    drop.Name = Title .. "_MultiDrop"
    drop.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    drop.BackgroundColor3 = OSX_Lib.Theme.CardBG
    drop.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    drop.ClipsDescendants = true
    drop.Parent = Parent

    Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", drop)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Header = Instance.new("TextButton", drop)
    Header.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""

    local Label = Instance.new("TextLabel", Header)
    Label.Size = UDim2.new(1, -50, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", Header)
        Desc.Size = UDim2.new(1, -50, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function UpdateHeader()
        local count = 0
        for val, state in pairs(Selected) do if state then count = count + 1 end end
        Label.Text = Title .. " (" .. count .. " selected)"
    end
    UpdateHeader()

    local Arrow = Instance.new("ImageLabel", Header)
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -30, 0.5, -8)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://10723415903"
    Arrow.Rotation = 0

    local List = Instance.new("Frame", drop)
    List.Position = UDim2.new(0, 0, 0, Description ~= "" and 60 or 42)
    List.Size = UDim2.new(1, 0, 0, #Values * 30 + 10)
    List.BackgroundTransparency = 1

    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 5)

    for i, v in ipairs(Values) do
        local Item = Instance.new("TextButton", List)
        Item.Size = UDim2.new(1, 0, 0, 25)
        Item.BackgroundTransparency = 1
        Item.Text = tostring(v)
        Item.TextColor3 = Selected[v] and OSX_Lib.Theme.Accent or OSX_Lib.Theme.TextDim
        Item.Font = Selected[v] and OSX_Lib.Theme.FontBold or OSX_Lib.Theme.Font
        Item.TextSize = 13

        Item.MouseButton1Click:Connect(function()
            Selected[v] = not Selected[v]
            Item.TextColor3 = Selected[v] and OSX_Lib.Theme.Accent or OSX_Lib.Theme.TextDim
            Item.Font = Selected[v] and OSX_Lib.Theme.FontBold or OSX_Lib.Theme.Font
            UpdateHeader()
            local res = {}
            for val, state in pairs(Selected) do if state then table.insert(res, val) end end
            Callback(res)
        end)
    end

    Header.MouseButton1Click:Connect(function()
        Open = not Open
        TweenService:Create(drop, TweenInfo.new(0.3), {Size = Open and UDim2.new(1, 0, 0, (Description ~= "" and 60 or 42) + List.Size.Y.Offset) or UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Open and 180 or 0}):Play()
    end)

    return drop
end

function OSX_Lib:Internal_AddKeybind(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Keybind"
    local Description = Config.Description or ""
    local Default = Config.Default or "None"
    local Callback = Config.Callback or function() end
    local Bind = Default

    local key = Instance.new("Frame")
    key.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    key.BackgroundColor3 = OSX_Lib.Theme.CardBG
    key.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    key.Parent = Parent

    Instance.new("UICorner", key).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", key)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Label = Instance.new("TextLabel", key)
    Label.Size = UDim2.new(0.6, 0, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", key)
        Desc.Size = UDim2.new(0.6, 0, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local BindBtn = Instance.new("TextButton", key)
    BindBtn.Size = UDim2.new(0, 80, 0, 24)
    BindBtn.Position = UDim2.new(1, -95, 0.5, -12)
    BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BindBtn.Text = tostring(Bind)
    BindBtn.TextColor3 = OSX_Lib.Theme.Accent
    BindBtn.Font = OSX_Lib.Theme.FontBold
    BindBtn.TextSize = 11
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

    local Binding = false
    BindBtn.MouseButton1Click:Connect(function()
        Binding = true
        BindBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(Input)
        if Binding and Input.UserInputType == Enum.UserInputType.Keyboard then
            Bind = Input.KeyCode.Name
            BindBtn.Text = Bind
            Binding = false
            Callback(Bind)
        elseif Input.KeyCode.Name == Bind then
            Callback(Bind, true)
        end
    end)

    return key
end

function OSX_Lib:Internal_AddInfoLabel(Parent, LabelText, ValueText, Desc)
    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, 0, 0, Desc and 55 or 35)
    info.BackgroundTransparency = 1
    info.Parent = Parent

    local L = Instance.new("TextLabel", info)
    L.Size = UDim2.new(0.4, 0, 0, 25)
    L.Position = UDim2.new(0, 0, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = LabelText
    L.TextColor3 = OSX_Lib.Theme.TextDim
    L.TextSize = 13
    L.Font = OSX_Lib.Theme.Font
    L.TextXAlignment = Enum.TextXAlignment.Left

    local V = Instance.new("TextLabel", info)
    V.Size = UDim2.new(0.6, 0, 0, 25)
    V.Position = UDim2.new(0.4, 0, 0, 0)
    V.BackgroundTransparency = 1
    V.Text = ValueText
    V.TextColor3 = OSX_Lib.Theme.TextMain
    V.TextSize = 13
    V.Font = OSX_Lib.Theme.FontBold
    V.TextXAlignment = Enum.TextXAlignment.Right

    if Desc then
        local D = Instance.new("TextLabel", info)
        D.Size = UDim2.new(1, 0, 0, 20)
        D.Position = UDim2.new(0, 0, 0, 25)
        D.BackgroundTransparency = 1
        D.Text = Desc
        D.TextColor3 = Color3.fromRGB(100, 100, 100)
        D.TextSize = 11
        D.Font = OSX_Lib.Theme.Font
        D.TextXAlignment = Enum.TextXAlignment.Left
    end

    return info
end

function OSX_Lib:Internal_AddLabel(Parent, Text)
    local lab = Instance.new("TextLabel", Parent)
    lab.Size = UDim2.new(1, 0, 0, 30)
    lab.BackgroundTransparency = 1
    lab.Text = Text
    lab.TextColor3 = OSX_Lib.Theme.TextMain
    lab.TextSize = 14
    lab.Font = OSX_Lib.Theme.Font
    lab.TextXAlignment = Enum.TextXAlignment.Left
    return lab
end

function OSX_Lib:Internal_AddSection(Parent, Text)
    local sec = Instance.new("Frame", Parent)
    sec.Size = UDim2.new(1, 0, 0, 40)
    sec.BackgroundTransparency = 1

    local lab = Instance.new("TextLabel", sec)
    lab.Size = UDim2.new(1, 0, 1, 0)
    lab.BackgroundTransparency = 1
    lab.Text = "  " .. Text:upper()
    lab.TextColor3 = OSX_Lib.Theme.Accent
    lab.TextSize = 12
    lab.Font = OSX_Lib.Theme.FontBold
    lab.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", sec)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -5)
    line.BackgroundColor3 = OSX_Lib.Theme.Accent
    line.BackgroundTransparency = 0.8
    line.BorderSizePixel = 0

    return sec
end

function OSX_Lib:Internal_AddParagraph(Parent, Title, Text)
    local par = Instance.new("Frame", Parent)
    par.BackgroundColor3 = OSX_Lib.Theme.CardBG
    par.BackgroundTransparency = 0.9
    par.Size = UDim2.new(1, 0, 0, 80)
    Instance.new("UICorner", par).CornerRadius = UDim.new(0, 8)

    local T = Instance.new("TextLabel", par)
    T.Size = UDim2.new(1, -20, 0, 25)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.BackgroundTransparency = 1
    T.Text = Title
    T.TextColor3 = OSX_Lib.Theme.TextMain
    T.Font = OSX_Lib.Theme.FontBold
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left

    local B = Instance.new("TextLabel", par)
    B.Size = UDim2.new(1, -20, 1, -30)
    B.Position = UDim2.new(0, 10, 0, 25)
    B.BackgroundTransparency = 1
    B.Text = Text
    B.TextColor3 = OSX_Lib.Theme.TextDim
    B.Font = OSX_Lib.Theme.Font
    B.TextSize = 12
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.TextYAlignment = Enum.TextYAlignment.Top
    B.TextWrapped = true

    return par
end

function OSX_Lib:Internal_AddWideButton(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Action"
    local Description = Config.Description or ""
    local Callback = Config.Callback or function() end

    local btn = Instance.new("TextButton", Parent)
    btn.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 45)
    btn.BackgroundColor3 = OSX_Lib.Theme.Accent
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local Label = Instance.new("TextLabel", btn)
    Label.Size = UDim2.new(1, 0, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.MainBG
    Label.TextSize = 15
    Label.Font = OSX_Lib.Theme.FontBold

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", btn)
        Desc.Size = UDim2.new(1, 0, 0.5, 0)
        Desc.Position = UDim2.new(0, 0, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.MainBG
        Desc.BackgroundTransparency = 1
        Desc.TextTransparency = 0.2
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
    end

    btn.MouseButton1Click:Connect(Callback)
    return btn
end

function OSX_Lib:Internal_AddColorPicker(Parent, Config)
    Config = Config or {}
    local Title = Config.Title or "Color Picker"
    local Description = Config.Description or ""
    local Default = Config.Default or Color3.fromRGB(255, 255, 255)
    local Callback = Config.Callback or function() end
    local Flag = Config.Flag or Title
    
    local H, S, V = Color3.toHSV(Default)
    local Open = false

    local cp = Instance.new("Frame")
    cp.Name = Title .. "_CP"
    cp.Size = UDim2.new(1, 0, 0, Description ~= "" and 60 or 42)
    cp.BackgroundColor3 = OSX_Lib.Theme.CardBG
    cp.BackgroundTransparency = OSX_Lib.Theme.CardTransparency
    cp.ClipsDescendants = true
    cp.Parent = Parent

    Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", cp)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = OSX_Lib.Theme.BorderTransparency

    local Header = Instance.new("TextButton", cp)
    Header.Size = UDim2.new(1, 0, 0, Description ~= "" and 55 or 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""

    local Label = Instance.new("TextLabel", Header)
    Label.Size = UDim2.new(1, -80, Description ~= "" and 0.45 or 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Title
    Label.TextColor3 = OSX_Lib.Theme.TextMain
    Label.TextSize = 14
    Label.Font = OSX_Lib.Theme.FontBold
    Label.TextXAlignment = Enum.TextXAlignment.Left

    if Description ~= "" then
        local Desc = Instance.new("TextLabel", Header)
        Desc.Size = UDim2.new(1, -80, 0.5, 0)
        Desc.Position = UDim2.new(0, 15, 0.5, 0)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = OSX_Lib.Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = OSX_Lib.Theme.Font
        Desc.TextXAlignment = Enum.TextXAlignment.Left
    end

    local ColorPreview = Instance.new("Frame", Header)
    ColorPreview.Size = UDim2.new(0, 45, 0, 24)
    ColorPreview.Position = UDim2.new(1, -60, 0.5, -12)
    ColorPreview.BackgroundColor3 = Default
    Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 6)

    -- EXPANDED AREA
    local Content = Instance.new("Frame", cp)
    Content.Position = UDim2.new(0, 0, 0, Description ~= "" and 55 or 42)
    Content.Size = UDim2.new(1, 0, 0, 150)
    Content.BackgroundTransparency = 1

    -- Hue Slider
    local HueSlider = Instance.new("Frame", Content)
    HueSlider.Position = UDim2.new(0, 15, 0, 10)
    HueSlider.Size = UDim2.new(1, -30, 0, 12)
    local HueGradient = Instance.new("UIGradient", HueSlider)
    HueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16, 1, 1)),
        ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 1, 1)),
        ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    })
    Instance.new("UICorner", HueSlider).CornerRadius = UDim.new(1, 0)

    local HueSelector = Instance.new("Frame", HueSlider)
    HueSelector.Size = UDim2.new(0, 6, 1, 4)
    HueSelector.Position = UDim2.new(H, -3, 0, -2)
    HueSelector.BackgroundColor3 = OSX_Lib.Theme.TextMain
    Instance.new("UICorner", HueSelector).CornerRadius = UDim.new(1, 0)

    -- Saturation/Value Picker
    local SVFrame = Instance.new("Frame", Content)
    SVFrame.Position = UDim2.new(0, 15, 0, 35)
    SVFrame.Size = UDim2.new(0.6, -20, 0, 100)
    SVFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
    Instance.new("UICorner", SVFrame).CornerRadius = UDim.new(0, 8)

    local WhiteGrad = Instance.new("ImageLabel", SVFrame)
    WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
    WhiteGrad.BackgroundTransparency = 1
    WhiteGrad.Image = "rbxassetid://15555416040" -- White-to-Transparent Gradient
    WhiteGrad.ImageColor3 = Color3.new(1,1,1)

    local BlackGrad = Instance.new("ImageLabel", SVFrame)
    BlackGrad.Size = UDim2.new(1, 0, 1, 0)
    BlackGrad.BackgroundTransparency = 1
    BlackGrad.Image = "rbxassetid://15555416040" -- Vertical black grad simulated or same asset rotated
    BlackGrad.Rotation = 90
    BlackGrad.ImageColor3 = Color3.new(0,0,0)

    local SVPicker = Instance.new("Frame", SVFrame)
    SVPicker.Size = UDim2.new(0, 10, 0, 10)
    SVPicker.Position = UDim2.new(S, -5, 1-V, -5)
    SVPicker.BackgroundColor3 = OSX_Lib.Theme.TextMain
    SVPicker.BorderSizePixel = 2
    SVPicker.BorderColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", SVPicker).CornerRadius = UDim.new(1, 0)

    -- Info Panel (Inputs)
    local InfoPanel = Instance.new("Frame", Content)
    InfoPanel.Position = UDim2.new(0.6, 5, 0, 35)
    InfoPanel.Size = UDim2.new(0.4, -20, 0, 100)
    InfoPanel.BackgroundTransparency = 1

    local HexInput = Instance.new("TextBox", InfoPanel)
    HexInput.Size = UDim2.new(1, 0, 0, 25)
    HexInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    HexInput.Text = ColorToHex(Default)
    HexInput.TextColor3 = OSX_Lib.Theme.TextMain
    HexInput.Font = OSX_Lib.Theme.Font
    HexInput.TextSize = 12
    Instance.new("UICorner", HexInput).CornerRadius = UDim.new(0, 6)

    local function Update()
        local FinalColor = Color3.fromHSV(H, S, V)
        ColorPreview.BackgroundColor3 = FinalColor
        SVFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        HexInput.Text = ColorToHex(FinalColor)
        
        OSX_Lib.Flags[Flag] = FinalColor
        OSX_Lib:SafeCallback(Callback, FinalColor)
    end

    -- Input Logic
    local DraggingHue = false
    HueSlider.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingHue = true end
    end)
    HueSlider.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingHue = false end
    end)
    
    local DraggingSV = false
    SVFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSV = true end
    end)
    SVFrame.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then DraggingSV = false end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if DraggingHue and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Percent = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
            H = Percent
            HueSelector.Position = UDim2.new(H, -3, 0, -2)
            Update()
        elseif DraggingSV and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local pX = math.clamp((Input.Position.X - SVFrame.AbsolutePosition.X) / SVFrame.AbsoluteSize.X, 0, 1)
            local pY = math.clamp((Input.Position.Y - SVFrame.AbsolutePosition.Y) / SVFrame.AbsoluteSize.Y, 0, 1)
            S = pX
            V = 1 - pY
            SVPicker.Position = UDim2.new(S, -5, 1-V, -5)
            Update()
        end
    end)

    HexInput.FocusLost:Connect(function()
        local success, result = pcall(function() return HexToColor(HexInput.Text) end)
        if success then
            H, S, V = Color3.toHSV(result)
            HueSelector.Position = UDim2.new(H, -3, 0, -2)
            SVPicker.Position = UDim2.new(S, -5, 1-V, -5)
            Update()
        end
    end)

    Header.MouseButton1Click:Connect(function()
        Open = not Open
        TweenService:Create(cp, TweenInfo.new(0.35, Enum.EasingStyle.Quart), {Size = Open and UDim2.new(1, 0, 0, 195) or UDim2.new(1, 0, 0, 42)}):Play()
    end)

    return cp
end

-- ==========================================
-- UPDATE POPUP SYSTEM (Stealth Center)
-- ==========================================

function OSX_Lib:Internal_AddUpdatePopup(Config)
    Config = Config or {}
    local TitleText = Config.Title or "Update Notes"
    local VersionText = Config.Version or OSX_Lib.Version
    local Changelog = Config.Changelog or {}
    local ButtonText = Config.ButtonText or "Continue"
    local Callback = Config.Callback or function() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OSX_UpdatePopup"
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = GetGuiParent()

    -- Transparent Input Blocker (Clear, no tint)
    local Overlay = Instance.new("TextButton", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.Text = ""
    Overlay.AutoButtonColor = false
    Overlay.BorderSizePixel = 0

    local MainCard = Instance.new("Frame", ScreenGui)
    MainCard.Name = "MainCard"
    MainCard.Size = UDim2.new(0, 420, 0, 340) -- Slightly taller for spacing
    MainCard.Position = UDim2.new(0.5, -210, 0.5, -170)
    MainCard.BackgroundColor3 = OSX_Lib.Theme.MainBG
    MainCard.BorderSizePixel = 0
    MainCard.ClipsDescendants = true
    MainCard.BackgroundTransparency = 1 -- Animating later

    Instance.new("UICorner", MainCard).CornerRadius = UDim.new(0, 15)
    local Stroke = Instance.new("UIStroke", MainCard)
    Stroke.Color = OSX_Lib.Theme.BorderColor
    Stroke.Transparency = 0.8
    Stroke.Thickness = 1.5

    -- Header (Improved Spacing)
    local TitleLabel = Instance.new("TextLabel", MainCard)
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0, 0, 0, 25) -- Moved down
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TitleText
    TitleLabel.TextColor3 = OSX_Lib.Theme.TextMain
    TitleLabel.TextSize = 20 -- Slightly larger
    TitleLabel.Font = OSX_Lib.Theme.FontBold

    local VerLabel = Instance.new("TextLabel", MainCard)
    VerLabel.Size = UDim2.new(1, 0, 0, 20)
    VerLabel.Position = UDim2.new(0, 0, 0, 55) -- Increased gap
    VerLabel.BackgroundTransparency = 1
    VerLabel.Text = "Version " .. VersionText
    VerLabel.TextColor3 = OSX_Lib.Theme.Accent
    VerLabel.TextSize = 13
    VerLabel.Font = OSX_Lib.Theme.Font

    -- Changelog Scroll Area
    local Scroll = Instance.new("ScrollingFrame", MainCard)
    Scroll.Name = "ChangelogArea"
    Scroll.Size = UDim2.new(1, -40, 0, 160)
    Scroll.Position = UDim2.new(0, 20, 0, 95) -- Moved down for header breathing room
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 0
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    OSX_Lib:ApplyCustomScroll(Scroll)

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 8)

    for i, msg in ipairs(Changelog) do
        local Line = Instance.new("TextLabel", Scroll)
        Line.Size = UDim2.new(1, 0, 0, 20)
        Line.BackgroundTransparency = 1
        Line.Text = "• " .. tostring(msg)
        Line.TextColor3 = OSX_Lib.Theme.TextDim
        Line.TextSize = 12
        Line.Font = OSX_Lib.Theme.Font
        Line.TextXAlignment = Enum.TextXAlignment.Left
        Line.TextWrapped = true
        Line.AutomaticSize = Enum.AutomaticSize.Y
    end

    -- Accept Button
    local AcceptBtn = Instance.new("TextButton", MainCard)
    AcceptBtn.Name = "AcceptBtn"
    AcceptBtn.Size = UDim2.new(1, -60, 0, 35)
    AcceptBtn.Position = UDim2.new(0, 30, 1, -55)
    AcceptBtn.BackgroundColor3 = OSX_Lib.Theme.Accent
    AcceptBtn.Text = ButtonText
    AcceptBtn.TextColor3 = Color3.fromRGB(0, 0, 0) -- High contrast
    AcceptBtn.Font = OSX_Lib.Theme.FontBold
    AcceptBtn.TextSize = 14
    AcceptBtn.AutoButtonColor = false

    Instance.new("UICorner", AcceptBtn).CornerRadius = UDim.new(0, 8)

    -- Animations
    TweenService:Create(Overlay, TweenInfo.new(0.5), {BackgroundTransparency = 0.5}):Play()
    MainCard.Size = UDim2.new(0, 336, 0, 256) -- Scale down start
    MainCard.Position = UDim2.new(0.5, -168, 0.5, -128)
    
    TweenService:Create(MainCard, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 420, 0, 340),
        Position = UDim2.new(0.5, -210, 0.5, -170),
        BackgroundTransparency = 0.05
    }):Play()

    AcceptBtn.MouseButton1Click:Connect(function()
        Callback()
        TweenService:Create(MainCard, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 336, 0, 256),
            Position = UDim2.new(0.5, -168, 0.5, -128),
            BackgroundTransparency = 1
        }):Play()

        task.wait(0.3)
        ScreenGui:Destroy()

        if OSX_Lib.MainUI then
            OSX_Lib.MainUI.Visible = true
            -- Fade in main ui
            OSX_Lib.MainUI.GroupTransparency = 1
            TweenService:Create(OSX_Lib.MainUI, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
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
    warn("OSX Lib: Initializing Window...")
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = GenerateRandomName(15)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    local Parent = GetGuiParent()
    if not Parent then 
        warn("OSX Lib ERROR: Could not find a safe parent for GUI!")
        return 
    end
    ScreenGui.Parent = Parent
    warn("OSX Lib: GUI Parented to " .. Parent.Name)

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
    OSX_Lib.MainUI = Main

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, OSX_Lib.Theme.CornerRadius)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = OSX_Lib.Theme.BorderColor
    MainStroke.Transparency = OSX_Lib.Theme.BorderTransparency
    MainStroke.Thickness = 1
    MainStroke.Parent = Main
    
    warn("OSX Lib: Drawing Header & Sidebar...")

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

    -- Unified Destruction Function
    local function DestroyWindow()
        OSX_Lib:DisconnectAll()
        if ScreenGui then ScreenGui:Destroy() end
        if FloatingGui then FloatingGui:Destroy() end
    end
    
    CloseBtn.MouseButton1Click:Connect(DestroyWindow)

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
    FloatingGui.Parent = GetGuiParent()

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
    warn("OSX Lib: Window is now Visible. Initializing Tabs...")
    
    MakeDraggable(Main, Header)
    MakeDraggable(FloatingFrame, FloatingFrame)

    local ToggleConnection
    ToggleConnection = UserInputService.InputBegan:Connect(function(Input)
        if Input.KeyCode == ToggleKey or Input.KeyCode == Enum.KeyCode.RightControl then
            if ScreenGui and ScreenGui.Parent then -- Only toggle if not destroyed
                SetUIVisible(not UI_Visible)
            end
        end
    end)

    -- Update Destroy logic to include connection
    local OriginalDestroy = DestroyWindow
    DestroyWindow = function()
        if ToggleConnection then ToggleConnection:Disconnect() end
        OriginalDestroy()
    end

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
        TabSubLabel.Name = "SubDescription"
        TabSubLabel.Size = UDim2.new(1, -55, 0, 16)
        TabSubLabel.Position = UDim2.new(0, 50, 0, 32)
        TabSubLabel.BackgroundTransparency = 1
        TabSubLabel.Text = TabSub
        TabSubLabel.TextColor3 = OSX_Lib.Theme.TextDim
        TabSubLabel.TextSize = 10
        TabSubLabel.Font = OSX_Lib.Theme.Font
        TabSubLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabSubLabel.TextYAlignment = Enum.TextYAlignment.Top
        TabSubLabel.TextTransparency = 0.5
        TabSubLabel.TextWrapped = true
        TabSubLabel.Parent = TabButton

        -- Tab Content
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = TabTitle .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Visible = false
        -- Enable Automatic Scrolling
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = Container
        
        OSX_Lib:ApplyCustomScroll(TabPage)

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
            
            -- Transition Animation
            TabPage.Position = UDim2.new(0, 0, 0, 10)
            TabPage.Visible = true
            
            TweenService:Create(TabPage, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0,0,0,0)}):Play()
            
            local Success, Error = pcall(function()
                if TabPage:IsA("CanvasGroup") then
                    TabPage.GroupTransparency = 1
                    TweenService:Create(TabPage, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()
                end
            end)
            
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
            PanelHeader.Position = UDim2.new(0, 20, 0, 10)
            PanelHeader.BackgroundTransparency = 1
            PanelHeader.Text = PanelTitle or ""
            PanelHeader.TextColor3 = OSX_Lib.Theme.TextMain
            PanelHeader.TextSize = 14
            PanelHeader.Font = OSX_Lib.Theme.FontBold
            PanelHeader.TextXAlignment = Enum.TextXAlignment.Left
            PanelHeader.Parent = PanelFrame

            local PanelList = Instance.new("Frame")
            PanelList.Name = "PanelList"
            PanelList.Position = UDim2.new(0, 0, 0, 65)
            PanelList.Size = UDim2.new(1, 0, 0, 0)
            PanelList.BackgroundTransparency = 1
            PanelList.Parent = PanelFrame

            local PanelLayout = Instance.new("UIListLayout")
            PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
            PanelLayout.Padding = UDim.new(0, 12)
            PanelLayout.Parent = PanelList

            local PanelPadding = Instance.new("UIPadding")
            PanelPadding.PaddingLeft = UDim.new(0, 20)
            PanelPadding.PaddingRight = UDim.new(0, 20)
            PanelPadding.PaddingBottom = UDim.new(0, 15)
            PanelPadding.Parent = PanelList

            PanelLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PanelFrame.Size = UDim2.new(1, 0, 0, PanelLayout.AbsoluteContentSize.Y + 80)
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
                function target:AddMultiDropdown(Config)
                    local multidrop = OSX_Lib:Internal_AddMultiDropdown(list, Config)
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
                    if Config.Tooltip then OSX_Lib:AddTooltip(color, Config.Tooltip) end
                    return target
                end
                
                function target:AddSubTab(SubConfig)
                    SubConfig = SubConfig or {}
                    local Titles = SubConfig.Titles or {"Main"}
                    local Callback = SubConfig.Callback or function() end
                    
                    local SubFrame = Instance.new("Frame")
                    SubFrame.Size = UDim2.new(1, 0, 0, 40)
                    SubFrame.BackgroundTransparency = 1
                    SubFrame.Parent = TabPage
                    
                    local SubLayout = Instance.new("UIListLayout")
                    SubLayout.FillDirection = Enum.FillDirection.Horizontal
                    SubLayout.Padding = UDim.new(0, 10)
                    SubLayout.Parent = SubFrame
                    
                    local SubPages = {}
                    local CurrentSub = nil
                    
                    local function SelectSub(btn, page, title)
                        if CurrentSub then
                            TweenService:Create(CurrentSub.btn, TweenInfo.new(0.3), {TextColor3 = OSX_Lib.Theme.TextDim}):Play()
                            CurrentSub.page.Visible = false
                        end
                        CurrentSub = {btn = btn, page = page}
                        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = OSX_Lib.Theme.Accent}):Play()
                        page.Visible = true
                        Callback(title)
                    end
                    
                    local SubMethods = {}
                    for i, title in ipairs(Titles) do
                        local SubBtn = Instance.new("TextButton", SubFrame)
                        SubBtn.Size = UDim2.new(0, 80, 1, 0)
                        SubBtn.BackgroundTransparency = 1
                        SubBtn.Text = title
                        SubBtn.TextColor3 = OSX_Lib.Theme.TextDim
                        SubBtn.Font = OSX_Lib.Theme.FontBold
                        SubBtn.TextSize = 13
                        
                        local SubPage = Instance.new("Frame", TabPage)
                        SubPage.Size = UDim2.new(1, 0, 0, 0)
                        SubPage.BackgroundTransparency = 1
                        SubPage.Visible = false
                        
                        local SubPageLayout = Instance.new("UIListLayout", SubPage)
                        SubPageLayout.Padding = UDim.new(0, 15)
                        SubPageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                            SubPage.Size = UDim2.new(1, 0, 0, SubPageLayout.AbsoluteContentSize.Y)
                        end)
                        
                        local m = {}
                        ApplyMethods(m, SubPage)
                        SubMethods[title] = m
                        
                        SubBtn.MouseButton1Click:Connect(function()
                            SelectSub(SubBtn, SubPage, title)
                        end)
                        
                        if i == 1 then SelectSub(SubBtn, SubPage, title) end
                    end
                    
                    return SubMethods
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
            function target:AddMultiDropdown(Config)
                OSX_Lib:Internal_AddMultiDropdown(page, Config)
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
            function target:AddInfoLabel(Label, Value, Desc)
                OSX_Lib:Internal_AddInfoLabel(page, Label, Value, Desc)
                return target
            end
            function target:AddWideButton(Config)
                OSX_Lib:Internal_AddWideButton(page, Config)
                return target
            end
            function target:AddColorPicker(Config)
                OSX_Lib:Internal_AddColorPicker(page, Config)
                if Config.Tooltip then OSX_Lib:AddTooltip(target, Config.Tooltip) end
                return target
            end
        end

        ApplyTabMethods(Elements, TabPage)

        if not CurrentTab then Select() end
        return Elements
    end

    local Window = {
        AddTab = function(self, TabConfig)
            return AddTab(TabConfig)
        end,
        ShowUpdate = function(self, UpdateConfig)
            OSX_Lib.MainUI.Visible = false
            OSX_Lib:Internal_AddUpdatePopup(UpdateConfig)
        end,
        Destroy = function(self)
            DestroyWindow()
        end
    }

    return Window
end

print('-----------------------------------------')
print('OSX UI Library: Stealth Monochrome Update')
print('Current Version: ' .. OSX_Lib.Version)
print('Latest Fix: ' .. OSX_Lib.UpdateLog[OSX_Lib.Version])
print('-----------------------------------------')
return OSX_Lib
