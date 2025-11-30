local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- // CONFIG // --
local UI_THEME = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 28),
    Card = Color3.fromRGB(25, 25, 35),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(160, 160, 170),
    Accent = Color3.fromRGB(60, 130, 250),
    Hover = Color3.fromRGB(35, 35, 45),
    ToggleOn = Color3.fromRGB(60, 130, 250),
    ToggleOff = Color3.fromRGB(50, 50, 60),
    ToggleBgOn = Color3.fromRGB(30, 70, 130)
}

local State = {
    Speed = { Active = false, Value = 16 },
    Jump = { Active = false, Value = 50 },
    Fly = { Active = false, Speed = 50 },
    Noclip = { Active = false },
    InfJump = { Active = false },
    ClickTP = { Active = false, Key = Enum.KeyCode.T },
    KillAura = { Active = false, Range = 15, TeamCheck = false, Visualizer = false },
    GodMode = { Active = false },
    ESP = { Active = false, TeamCheck = false },
    AntiAFK = { Active = false },
    NoStun = { Active = false },
    GhostMode = { Active = false },
    Bypass = { Active = false },
    Aimbot = { 
        Active = false, 
        ShowFOV = false, 
        FOV = 100, 
        TeamCheck = false, 
        Key = Enum.KeyCode.E,
        Smoothing = 0.5,
        ExcludedTeams = {
            ["Guards"] = false,
            ["Inmates"] = false,
            ["Criminals"] = false
        }
    },
    SilentAim = { Active = false, TeamCheck = false, FOV = 100 },
    Hitbox = { Active = false, Size = 5, TeamCheck = false },
    GunMods = { NoSpread = false, FastReload = false, AutoFire = false, InfAmmo = false, RapidFire = false },
    AutoArrest = { Active = false, Range = 15 },
    Fling = { Active = true, Speed = 500 },
    Fullbright = { Active = false },
    FOV = { Value = 70 },
    XRay = { Active = false },
    AntiKick = { Active = false },
    AntiTase = { Active = false }
}

-- // FOV CIRCLE // --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1

-- // VISUALIZER & REACH // --
local rangeVisualizer = nil
local originalSizes = {}
local espFolder = Instance.new("Folder", playerGui)
espFolder.Name = "PRISON_ESP"

-- // UI LIBRARY // --
local Library = {}

function Library:Create(titleText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PRISON_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ScreenGui.Parent = playerGui
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
    MainFrame.BackgroundColor3 = UI_THEME.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 50)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = MainFrame
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = UI_THEME.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    local SidebarGrad = Instance.new("UIGradient")
    SidebarGrad.Rotation = 45
    SidebarGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    }
    SidebarGrad.Parent = Sidebar
    
    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 10, 1, 0)
    SidebarFix.Position = UDim2.new(1, -10, 0, 0)
    SidebarFix.BackgroundColor3 = Color3.fromRGB(12, 12, 18) 
    SidebarFix.BorderSizePixel = 0
    SidebarFix.Parent = Sidebar
    
    local ControlsFrame = Instance.new("Frame")
    ControlsFrame.Size = UDim2.new(0, 60, 0, 20)
    ControlsFrame.Position = UDim2.new(0, 15, 0, 15)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.Parent = Sidebar
    
    local function CreateControlBtn(color, pos, callback)
        local btn = Instance.new("TextButton")
        btn.Text = ""
        btn.Size = UDim2.new(0, 12, 0, 12)
        btn.Position = UDim2.new(0, pos, 0.5, -6)
        btn.BackgroundColor3 = color
        btn.AutoButtonColor = false
        btn.Parent = ControlsFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function() 
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play() 
        end)
        btn.MouseLeave:Connect(function() 
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() 
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    CreateControlBtn(Color3.fromRGB(255, 95, 87), 0, function()
        MainFrame.Visible = false
    end)
    
    local minimized = false
    CreateControlBtn(Color3.fromRGB(255, 189, 46), 20, function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 50)}):Play()
            ContentArea.Visible = false
            TabContainer.Visible = false
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 480)}):Play()
            task.delay(0.2, function()
                ContentArea.Visible = true
                TabContainer.Visible = true
            end)
        end
    end)
    
    local maximized = false
    CreateControlBtn(Color3.fromRGB(39, 201, 63), 40, function()
        maximized = not maximized
        if maximized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 800, 0, 600)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 480)}):Play()
        end
    end)
    
    local Title = Instance.new("TextLabel")
    Title.Text = titleText
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 20 -- Reduced size
    Title.TextColor3 = UI_THEME.Accent
    Title.Size = UDim2.new(1, -30, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 45)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Sidebar
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Text = "PREMIUM TOOL"
    SubTitle.Font = Enum.Font.GothamBold
    SubTitle.TextSize = 10
    SubTitle.TextColor3 = UI_THEME.SubText
    SubTitle.Size = UDim2.new(1, 0, 0, 15)
    SubTitle.Position = UDim2.new(0, 2, 0, 24) -- Adjusted position relative to Title
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = Title
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -120)
    TabContainer.Position = UDim2.new(0, 0, 0, 120)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 15)
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.Parent = TabContainer
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -200, 1, 0)
    ContentArea.Position = UDim2.new(0, 200, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    local Pages = {}
    local Tabs = {}
    local CurrentTab = nil
    
    local function SwitchTab(tabName)
        if CurrentTab then
            TweenService:Create(CurrentTab.Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                TextColor3 = UI_THEME.SubText
            }):Play()
            CurrentTab.Page.Visible = false
        end
        
        local newTab = Tabs[tabName]
        if newTab then
            TweenService:Create(newTab.Btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.9,
                BackgroundColor3 = UI_THEME.Accent,
                TextColor3 = UI_THEME.Accent
            }):Play()
            newTab.Page.Visible = true
            
            newTab.Page.CanvasPosition = Vector2.new(0, 0)
            for _, child in ipairs(newTab.Page:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    child.BackgroundTransparency = 1
                    TweenService:Create(child, TweenInfo.new(0.4), {BackgroundTransparency = child:GetAttribute("OriginalTrans") or 0}):Play()
                end
            end
            
            CurrentTab = newTab
        end
    end
    
    local Window = {}
    
    function Window:Tab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -30, 0, 40)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn
        
        local IconFrame = Instance.new("ImageLabel")
        IconFrame.Size = UDim2.new(0, 18, 0, 18)
        IconFrame.Position = UDim2.new(0, 12, 0.5, -9)
        IconFrame.BackgroundTransparency = 1
        IconFrame.Image = icon or "rbxassetid://7072717950"
        IconFrame.ImageColor3 = UI_THEME.SubText
        IconFrame.Parent = TabBtn
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Text = name
        TitleLabel.Font = Enum.Font.GothamSemibold
        TitleLabel.TextSize = 14
        TitleLabel.TextColor3 = UI_THEME.SubText
        TitleLabel.Size = UDim2.new(1, -45, 1, 0)
        TitleLabel.Position = UDim2.new(0, 45, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = TabBtn
        
        TabBtn.MouseEnter:Connect(function()
            if CurrentTab and CurrentTab.Btn == TabBtn then return end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.95, BackgroundColor3 = Color3.new(1,1,1)}):Play()
            TweenService:Create(IconFrame, TweenInfo.new(0.2), {ImageColor3 = UI_THEME.Text}):Play()
            TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = UI_THEME.Text}):Play()
        end)
        TabBtn.MouseLeave:Connect(function()
            if CurrentTab and CurrentTab.Btn == TabBtn then return end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(IconFrame, TweenInfo.new(0.2), {ImageColor3 = UI_THEME.SubText}):Play()
            TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = UI_THEME.SubText}):Play()
        end)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Size = UDim2.new(1, -30, 1, -30)
        Page.Position = UDim2.new(0, 15, 0, 15)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = UI_THEME.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y -- FIX: Enable auto scrolling
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.Parent = ContentArea
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.Parent = Page
        
        Tabs[name] = {Btn = TabBtn, Page = Page}
        
        TabBtn.MouseButton1Click:Connect(function()
            SwitchTab(name)
        end)
        
        if not CurrentTab then SwitchTab(name) end
        
        local TabObj = {}
        
        function TabObj:Section(text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Text = text:upper()
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = 11
            SectionLabel.TextColor3 = UI_THEME.SubText
            SectionLabel.Size = UDim2.new(1, 0, 0, 30)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Page
        end
        
        function TabObj:Toggle(text, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
            ToggleFrame.BackgroundColor3 = UI_THEME.Card
            ToggleFrame:SetAttribute("OriginalTrans", 0)
            ToggleFrame.Parent = Page
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 8)
            TCorner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = UI_THEME.Text
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Switch = Instance.new("TextButton")
            Switch.Text = ""
            Switch.Size = UDim2.new(0, 44, 0, 24)
            Switch.Position = UDim2.new(1, -60, 0.5, -12)
            Switch.BackgroundColor3 = default and UI_THEME.ToggleBgOn or UI_THEME.ToggleOff
            Switch.Parent = ToggleFrame
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            Knob.BackgroundColor3 = UI_THEME.ToggleOn
            Knob.Parent = Switch
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(1, 0)
            KCorner.Parent = Knob
            
            local toggled = default
            
            Switch.MouseButton1Click:Connect(function()
                toggled = not toggled
                TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = toggled and UI_THEME.ToggleBgOn or UI_THEME.ToggleOff
                }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                }):Play()
                callback(toggled)
            end)
        end
        
        function TabObj:Slider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 55)
            SliderFrame.BackgroundColor3 = UI_THEME.Card
            SliderFrame:SetAttribute("OriginalTrans", 0)
            SliderFrame.Parent = Page
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 8)
            SCorner.Parent = SliderFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = UI_THEME.Text
            Label.Size = UDim2.new(0.5, 0, 0, 30)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Text = tostring(default)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 14
            ValueLabel.TextColor3 = UI_THEME.Accent
            ValueLabel.Size = UDim2.new(0.5, -15, 0, 30)
            ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local BarBg = Instance.new("Frame")
            BarBg.Size = UDim2.new(1, -30, 0, 6)
            BarBg.Position = UDim2.new(0, 15, 0, 35)
            BarBg.BackgroundColor3 = UI_THEME.ToggleOff
            BarBg.Parent = SliderFrame
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = BarBg
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = UI_THEME.Accent
            Fill.Parent = BarBg
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Trigger = Instance.new("TextButton")
            Trigger.Text = ""
            Trigger.BackgroundTransparency = 1
            Trigger.Size = UDim2.new(1, 0, 1, 0)
            Trigger.Parent = BarBg
            
            local dragging = false
            
            local function Update(input)
                local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ((max - min) * pos))
                
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(value)
                callback(value)
            end
            
            Trigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
        end
        
        function TabObj:Button(text, callback)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Text = ""
            BtnFrame.Size = UDim2.new(1, 0, 0, 45)
            BtnFrame.BackgroundColor3 = UI_THEME.Card
            BtnFrame:SetAttribute("OriginalTrans", 0)
            BtnFrame.Parent = Page
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 8)
            BCorner.Parent = BtnFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = UI_THEME.Text
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame
            
            local Icon = Instance.new("ImageLabel")
            Icon.Image = "rbxassetid://7072720450"
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(1, -35, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.ImageColor3 = UI_THEME.Accent
            Icon.Parent = BtnFrame
            
            BtnFrame.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.Hover}):Play()
            end)
            BtnFrame.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.Card}):Play()
            end)
            
            BtnFrame.MouseButton1Click:Connect(function()
                callback()
            end)
        end
        
        function TabObj:Input(text, default, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 45)
            InputFrame.BackgroundColor3 = UI_THEME.Card
            InputFrame:SetAttribute("OriginalTrans", 0)
            InputFrame.Parent = Page
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0, 8)
            ICorner.Parent = InputFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = UI_THEME.Text
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Text = default
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 13
            TextBox.TextColor3 = UI_THEME.Text
            TextBox.PlaceholderText = "..."
            TextBox.Size = UDim2.new(0.3, 0, 0.7, 0)
            TextBox.Position = UDim2.new(0.65, 0, 0.15, 0)
            TextBox.BackgroundColor3 = UI_THEME.Background
            TextBox.Parent = InputFrame
            
            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 6)
            TBCorner.Parent = TextBox
            
            TextBox.Focused:Connect(function()
                TweenService:Create(TextBox, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.Hover}):Play()
            end)
            
            TextBox.FocusLost:Connect(function(enterPressed)
                TweenService:Create(TextBox, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.Background}):Play()
                callback(TextBox.Text)
            end)
        end
        
        function TabObj:Keybind(text, default, callback)
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Size = UDim2.new(1, 0, 0, 45)
            KeyFrame.BackgroundColor3 = UI_THEME.Card
            KeyFrame:SetAttribute("OriginalTrans", 0)
            KeyFrame.Parent = Page
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(0, 8)
            KCorner.Parent = KeyFrame
            
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 14
            Label.TextColor3 = UI_THEME.Text
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = KeyFrame
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Text = default.Name
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.TextSize = 13
            BindBtn.TextColor3 = UI_THEME.Accent
            BindBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
            BindBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
            BindBtn.BackgroundColor3 = UI_THEME.Background
            BindBtn.Parent = KeyFrame
            
            local BBCorner = Instance.new("UICorner")
            BBCorner.CornerRadius = UDim.new(0, 6)
            BBCorner.Parent = BindBtn
            
            local listening = false
            
            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = UI_THEME.Text
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = UI_THEME.Accent
                        callback(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                        listening = false
                        BindBtn.Text = input.UserInputType.Name
                        BindBtn.TextColor3 = UI_THEME.Accent
                        callback(input.UserInputType)
                    end
                end
            end)
        end
        
        return TabObj
    end
    
    return Window
end

-- // MAIN LOGIC // --

local Window = Library:Create("BCODE PRISON")
local Home = Window:Tab("Home", "rbxassetid://7733960981")

--Home:Section("Welcome to BCODE PRISON HUB") -- Removed redundant header
--Home:Section("PRISON PREMIUM TOOL") -- Removed redundant header
Home:Button("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)
Home:Button("Server Hop", function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in ipairs(servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
            break
        end
    end
end)
Home:Toggle("Anti-AFK", false, function(v) 
    State.AntiAFK.Active = v 
end)

-- MOVEMENT TAB
local Movement = Window:Tab("Movement", "rbxassetid://7733964640")
Movement:Section("Speed & Jump")
Movement:Toggle("Speed Hack", false, function(v) State.Speed.Active = v end)
Movement:Slider("Speed Value", 16, 200, 16, function(v) State.Speed.Value = v end)
Movement:Toggle("High Jump", false, function(v) State.Jump.Active = v end)
Movement:Slider("Jump Power", 50, 300, 50, function(v) State.Jump.Value = v end)
Movement:Toggle("Infinite Jump", false, function(v) State.InfJump.Active = v end)

Movement:Section("Flight & Physics")
Movement:Toggle("Fly", false, function(v) State.Fly.Active = v end)
Movement:Slider("Fly Speed", 10, 200, 50, function(v) State.Fly.Speed = v end)
Movement:Toggle("Noclip", false, function(v) State.Noclip.Active = v end)
Movement:Button("Remove Jump Cooldown", function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Character.Humanoid:GetPropertyChangedSignal("Jump"))) do
            conn:Disable()
        end
    end
end)
-- COMBAT TAB
local Combat = Window:Tab("Combat", "rbxassetid://7733674847")

Combat:Section("Aimbot")
Combat:Toggle("Aimbot Active", false, function(v) State.Aimbot.Active = v end)
Combat:Toggle("Show FOV", false, function(v) State.Aimbot.ShowFOV = v end)
Combat:Slider("FOV Radius", 50, 500, 100, function(v) State.Aimbot.FOV = v end)
Combat:Slider("Smoothing", 1, 10, 5, function(v) State.Aimbot.Smoothing = v / 10 end)
Combat:Toggle("Team Check", false, function(v) State.Aimbot.TeamCheck = v end)
Combat:Keybind("Toggle Key", Enum.KeyCode.E, function(v) State.Aimbot.Key = v end)

Combat:Section("Aimbot Exclusions")
Combat:Toggle("Exclude Guards", false, function(v) State.Aimbot.ExcludedTeams["Guards"] = v end)
Combat:Toggle("Exclude Inmates", false, function(v) State.Aimbot.ExcludedTeams["Inmates"] = v end)
Combat:Toggle("Exclude Criminals", false, function(v) State.Aimbot.ExcludedTeams["Criminals"] = v end)

Combat:Section("Silent Aim")
Combat:Toggle("Silent Aim (Coming Soon)", false, function(v) State.SilentAim.Active = v end)
Combat:Slider("Silent FOV", 50, 500, 100, function(v) State.SilentAim.FOV = v end)
Combat:Toggle("Team Check", false, function(v) State.SilentAim.TeamCheck = v end)

Combat:Section("Gun Mods")
Combat:Toggle("No Spread", false, function(v) State.GunMods.NoSpread = v end)
Combat:Toggle("Fast Reload", false, function(v) State.GunMods.FastReload = v end)
Combat:Toggle("Auto Fire", false, function(v) State.GunMods.AutoFire = v end)
Combat:Toggle("Infinite Ammo", false, function(v) State.GunMods.InfAmmo = v end)
Combat:Toggle("Rapid Fire", false, function(v) State.GunMods.RapidFire = v end)

Combat:Section("Hitbox Expander")
Combat:Toggle("Expand Hitbox", false, function(v) State.Hitbox.Active = v end)
Combat:Slider("Size", 2, 10, 5, function(v) State.Hitbox.Size = v end)
Combat:Toggle("Hitbox Team Check", false, function(v) State.Hitbox.TeamCheck = v end)

-- GUARD TAB
local Guard = Window:Tab("Guard", "rbxassetid://7733965184")
Guard:Section("Auto Arrest")
Guard:Slider("Arrest Range", 5, 30, 15, function(v) State.AutoArrest.Range = v end)

-- TOOLS TAB
local Tools = Window:Tab("Tools", "rbxassetid://7733964240")
Tools:Section("Teams")
Tools:Button("Join Guards", function()
    Workspace.Remote.TeamEvent:FireServer("Bright blue")
end)
Tools:Button("Criminal Base", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-943, 94, 2063)
    end
end)
Tools:Button("Prison Yard", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(791, 98, 2498)
    end
end)
Tools:Button("Guard Room", function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(836, 99, 2307)
    end
end)

Combat:Section("Protection")
Combat:Toggle("No Stun", false, function(v) State.NoStun.Active = v end)
Combat:Toggle("God Mode", false, function(v) State.GodMode.Active = v end)
Combat:Toggle("Anti-Kick (Anti-Ban)", false, function(v) State.AntiKick.Active = v end)
Combat:Toggle("Anti-Tase", false, function(v) State.AntiTase.Active = v end)

-- VISUALS TAB
local Visuals = Window:Tab("Visuals", "rbxassetid://7733965639")
Visuals:Section("Visuals")
Visuals:Toggle("ESP Players", false, function(v)
    State.ESP.Active = v
    if not v then espFolder:ClearAllChildren() end
end)
Visuals:Toggle("Hide Teammates", false, function(v)
    State.ESP.TeamCheck = v
end)
Visuals:Toggle("Ghost Mode", false, function(v)
    State.GhostMode.Active = v
end)
Visuals:Toggle("Fullbright", false, function(v)
    State.Fullbright.Active = v
end)
Visuals:Slider("Camera FOV", 60, 120, 70, function(v)
    State.FOV.Value = v
end)
Visuals:Toggle("X-Ray (Walls)", false, function(v)
    State.XRay.Active = v
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") and not part.Parent:IsA("Tool") then
            part.Transparency = v and 0.5 or 0
        end
    end
end)

-- // LOGIC LOOPS // --

-- ESP Loop
task.spawn(function()
    while task.wait(1) do
        if State.ESP.Active then
            espFolder:ClearAllChildren()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if State.ESP.TeamCheck and p.Team == player.Team then
                        continue
                    end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = p.Character
                    highlight.FillColor = p.TeamColor.Color
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = p.TeamColor.Color
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                    
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = p.Character.HumanoidRootPart
                    bg.Size = UDim2.new(0, 200, 0, 50)
                    bg.StudsOffset = Vector3.new(0, 3.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = espFolder
                    
                    local name = Instance.new("TextLabel")
                    name.Text = p.Name .. " [" .. math.floor((player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                    name.Size = UDim2.new(1,0,1,0)
                    name.BackgroundTransparency = 1
                    name.TextColor3 = p.TeamColor.Color
                    name.TextStrokeTransparency = 0
                    name.Font = Enum.Font.GothamBold
                    name.TextSize = 14
                    name.Parent = bg
                end
            end
        end
    end
end)
-- Speed (CFrame Bypass & Velocity Spoof)
RunService.Heartbeat:Connect(function(dt)
    if State.Speed.Active and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            -- Move via CFrame
            root.CFrame = root.CFrame + (hum.MoveDirection * (State.Speed.Value - 16) * dt)
            -- Reset Velocity to prevent server detection (preserve gravity)
            local currentVel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Fly (CFrame Bypass & Velocity Spoof)
RunService.Heartbeat:Connect(function(dt)
    if State.Fly.Active and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChild("Humanoid")
        
        if root and hum then
            -- Calculate movement
            local cam = Workspace.CurrentCamera
            local moveDir = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame + (moveDir.Unit * State.Fly.Speed * dt)
            end
            
            -- Reset Velocity
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Prevent falling animation
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    else
        -- Cleanup Fly
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
end)

-- Anti-Cheat Remover (Client Side)
task.spawn(function()
    while task.wait(1) do
        if player.Character then
            local ac = player.Character:FindFirstChild("Client") -- Common AC script name in Prison Life
            if ac and ac:IsA("LocalScript") then
                ac:Destroy()
                -- warn("Removed Client AC Script")
            end
        end
    end
end)

-- No Stun
task.spawn(function()
    while task.wait(0.1) do
        if State.NoStun.Active and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
            
            for _, child in pairs(player.Character:GetChildren()) do
                if child.Name:lower():find("stun") then child:Destroy() end
            end
            for attr, _ in pairs(player.Character:GetAttributes()) do
                if attr:lower():find("stun") then player.Character:SetAttribute(attr, false) end
            end
        end
    end
end)

-- Aimbot & FOV Circle
RunService.RenderStepped:Connect(function()
    pcall(function()
        local mousePos = UserInputService:GetMouseLocation()
        
        -- Update FOV Circle
        if State.Aimbot.ShowFOV then
            FOVCircle.Position = mousePos
            FOVCircle.Radius = State.Aimbot.FOV
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end

        if State.Aimbot.Active then
            -- Tool Check Removed (Works without tool)
            -- local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            -- if not tool or not tool:FindFirstChild("GunStates") then return end

            local closest = nil
            local maxDist = State.Aimbot.FOV
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    if State.Aimbot.TeamCheck and p.Team == player.Team then continue end
                    
                    -- Safe Team Exclusion Check
                    if p.Team then
                        local teamName = p.Team.Name
                        if State.Aimbot.ExcludedTeams and State.Aimbot.ExcludedTeams[teamName] then
                            continue
                        end
                    end
                    
                    local pos, vis = camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = p.Character.Head
                        end
                    end
                end
            end
            
            if closest then
                -- Smooth Aiming using Lerp
                local targetCFrame = CFrame.new(camera.CFrame.Position, closest.Position)
                local smooth = math.clamp(State.Aimbot.Smoothing or 0.5, 0.1, 1)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, smooth)
            end
        end
    end)
end)

-- Silent Aim (Prison Life Specific Fix)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootEvent = ReplicatedStorage:FindFirstChild("ShootEvent")

local oldNamecall
if hookmetamethod then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if State.SilentAim.Active and method == "FireServer" and self.Name == "ShootEvent" then
            local success, err = pcall(function()
                -- Find nearest player to mouse
                local mousePos = UserInputService:GetMouseLocation()
                local closest = nil
                local maxDist = State.Aimbot.FOV -- Share FOV with Aimbot
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        if State.SilentAim.TeamCheck and p.Team == player.Team then continue end
                        
                        local pos, vis = camera:WorldToViewportPoint(p.Character.Head.Position)
                        if vis then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < maxDist then
                                maxDist = dist
                                closest = p.Character.Head
                            end
                        end
                    end
                end
                
                if closest and args[1] then
                    -- Prison Life ShootEvent args: (Ray, HitPart, HitPosition)
                    -- We need to spoof the Ray to point at the enemy
                    
                    local origin = args[1].Origin
                    local direction = (closest.Position - origin).Unit * 1000
                    local newRay = Ray.new(origin, direction)
                    
                    args[1] = newRay -- Spoofed Ray
                    args[2] = closest -- HitPart
                    args[3] = closest.Position -- HitPosition
                end
            end)
            if not success then warn("Silent Aim Error:", err) end
            
            if args[1] and args[1].Unit then -- Check if spoofing happened
                 return oldNamecall(self, unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end)
else
    warn("Executor does not support hookmetamethod. Silent Aim will not work.")
end

-- Anti-Kick Hook
-- Anti-Kick Hook (Robust)
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if State.AntiKick.Active then
            if method:lower() == "kick" and self == player then
                return nil -- Block Kick
            end
            if method:lower() == "shutdown" then
                return nil -- Block Shutdown
            end
        end
        
        -- Anti-Tase Hook
        if State.AntiTase.Active and method:lower() == "fireserver" and self.Name == "PlayerTased" then
            return nil -- Block Tase
        end
        
        return oldNamecall(self, ...)
    end)
    
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if State.AntiKick.Active then
            if tostring(key):lower() == "kick" and self == player then
                return function() end -- Return dummy function
            end
            if tostring(key):lower() == "shutdown" then
                return function() end
            end
        end
        return oldIndex(self, key)
    end)
end

-- Jump
UserInputService.JumpRequest:Connect(function()
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if State.InfJump.Active and hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if State.Jump.Active and hum and root then
            hum.UseJumpPower = true
            hum.JumpPower = State.Jump.Value
            -- Force Jump State to bypass Property Signal
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly
local bodyGyro, bodyVel
RunService.RenderStepped:Connect(function()
    if State.Fly.Active and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")
        local camCF = camera.CFrame
        
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
            hum.PlatformStand = true
        end
        
        bodyGyro.CFrame = camCF
        local speed = State.Fly.Speed
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + camCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - camCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - camCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + camCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, speed/2, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, speed/2, 0) end
        
        bodyVel.Velocity = velocity
    elseif bodyGyro then
        bodyGyro:Destroy() bodyGyro = nil
        bodyVel:Destroy() bodyVel = nil
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip.Active and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- Auto Arrest (Fixed)
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoArrest.Active and player.Character then
            if myRoot then
                -- Equip Handcuffs if needed
                local handcuffs = player.Backpack:FindFirstChild("Handcuffs")
                if handcuffs then 
                    player.Character.Humanoid:EquipTool(handcuffs) 
                end
                
                local equipped = player.Character:FindFirstChild("Handcuffs")
                if equipped then
                    for _, other in pairs(Players:GetPlayers()) do
                        if other ~= player and other.Team.Name == "Criminals" and other.Character then
                            local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
                            if oRoot then
                                local dist = (oRoot.Position - myRoot.Position).Magnitude
                                if dist <= State.AutoArrest.Range then
                                    workspace.Remote.arrest:InvokeServer(oRoot)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Fullbright Loop
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    while task.wait(1) do
        if State.Fullbright.Active then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
end)

-- FOV Loop
RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.FieldOfView = State.FOV.Value
end)

-- God Mode (RenderStepped & Event)
RunService.RenderStepped:Connect(function()
    if State.GodMode.Active then
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.Health = hum.MaxHealth 
                hum.BreakJointsOnDeath = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                
                -- Instant Heal Listener
                if not hum:FindFirstChild("GodModeConn") then
                    local conn = hum.HealthChanged:Connect(function(hp)
                        if hp < hum.MaxHealth then hum.Health = hum.MaxHealth end
                    end)
                    -- Store connection to avoid duplicates (using a dummy value to flag)
                    local flag = Instance.new("BoolValue", hum)
                    flag.Name = "GodModeConn"
                end
            end
            
            -- Anti-Touch (Melee Immunity)
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= player and other.Character then
                    local tool = other.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local touch = tool.Handle:FindFirstChild("TouchInterest")
                        if touch then touch:Destroy() end
                    end
                end
            end
        end
    end
end)

-- Ghost Mode
RunService.Stepped:Connect(function()
    if State.GhostMode.Active and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
            end
        end
    end
end)

-- UI Toggle & Click TP
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        -- Aimbot Toggle Key
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        if State.InfJump.Active and hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if State.Jump.Active and hum and root then
            hum.UseJumpPower = true
            hum.JumpPower = State.Jump.Value
            -- Force Jump State to bypass Property Signal
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Fly
local bodyGyro, bodyVel
RunService.RenderStepped:Connect(function()
    if State.Fly.Active and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")
        local camCF = camera.CFrame
        
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
            hum.PlatformStand = true
        end
        
        bodyGyro.CFrame = camCF
        local speed = State.Fly.Speed
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + camCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - camCF.LookVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - camCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + camCF.RightVector * speed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, speed/2, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, speed/2, 0) end
        
        bodyVel.Velocity = velocity
    elseif bodyGyro then
        bodyGyro:Destroy() bodyGyro = nil
        bodyVel:Destroy() bodyVel = nil
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip.Active and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- Auto Arrest (Fixed)
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoArrest.Active and player.Character then
            if myRoot then
                -- Equip Handcuffs if needed
                local handcuffs = player.Backpack:FindFirstChild("Handcuffs")
                if handcuffs then 
                    player.Character.Humanoid:EquipTool(handcuffs) 
                end
                
                local equipped = player.Character:FindFirstChild("Handcuffs")
                if equipped then
                    for _, other in pairs(Players:GetPlayers()) do
                        if other ~= player and other.Team.Name == "Criminals" and other.Character then
                            local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
                            if oRoot then
                                local dist = (oRoot.Position - myRoot.Position).Magnitude
                                if dist <= State.AutoArrest.Range then
                                    workspace.Remote.arrest:InvokeServer(oRoot)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Fullbright Loop
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    while task.wait(1) do
        if State.Fullbright.Active then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
end)

-- FOV Loop
RunService.RenderStepped:Connect(function()
    workspace.CurrentCamera.FieldOfView = State.FOV.Value
end)

-- God Mode (RenderStepped & Event)
RunService.RenderStepped:Connect(function()
    if State.GodMode.Active then
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.Health = hum.MaxHealth 
                hum.BreakJointsOnDeath = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                
                -- Instant Heal Listener
                if not hum:FindFirstChild("GodModeConn") then
                    local conn = hum.HealthChanged:Connect(function(hp)
                        if hp < hum.MaxHealth then hum.Health = hum.MaxHealth end
                    end)
                    -- Store connection to avoid duplicates (using a dummy value to flag)
                    local flag = Instance.new("BoolValue", hum)
                    flag.Name = "GodModeConn"
                end
            end
            
            -- Anti-Touch (Melee Immunity)
            for _, other in pairs(Players:GetPlayers()) do
                if other ~= player and other.Character then
                    local tool = other.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local touch = tool.Handle:FindFirstChild("TouchInterest")
                        if touch then touch:Destroy() end
                    end
                end
            end
        end
    end
end)

-- Ghost Mode
RunService.Stepped:Connect(function()
    if State.GhostMode.Active and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
            end
        end
    end
end)

-- Safe Seat Logic
local SafeSeat = Instance.new("Seat")
SafeSeat.Name = "BCODE_SafeSeat"
SafeSeat.Size = Vector3.new(4, 1, 4)
SafeSeat.Position = Vector3.new(-1000, 150, 1750) -- Underground to avoid sky detection
SafeSeat.Anchored = true
SafeSeat.CanCollide = true
SafeSeat.Transparency = 0.5
SafeSeat.Parent = workspace

local LastPos = nil

-- UI Toggle & Click TP
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp then
        -- Aimbot Toggle Key
        if input.KeyCode == State.Aimbot.Key then
            State.Aimbot.Active = not State.Aimbot.Active
        end
        
        -- Fly Toggle Key (.)
        if input.KeyCode == Enum.KeyCode.Period then
            State.Fly.Active = not State.Fly.Active
        end

        -- Safe Seat Key (Z)
        if input.KeyCode == Enum.KeyCode.Z then
            if player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if hum and root then
                    -- Save Position
                    LastPos = root.CFrame
                    -- Teleport to Safe Seat
                    root.CFrame = SafeSeat.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.1)
                    SafeSeat:Sit(hum)
                end
            end
        end
        
        -- Unsit / Return Key (Space)
        if input.KeyCode == Enum.KeyCode.Space then
            if player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Sit then
                    hum.Sit = false
                    -- If we were in the Safe Seat, return to last pos
                    if (root.Position - SafeSeat.Position).Magnitude < 10 and LastPos then
                        task.wait(0.1)
                        root.CFrame = LastPos
                    end
                end
            end
        end
        
        -- UI Toggle (Left Control)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            local gui = playerGui:FindFirstChild("PRISON_UI")
            if gui then
                local frame = gui:FindFirstChild("MainFrame")
                if frame then
                    if frame.Visible then
                        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                        task.wait(0.3)
                        frame.Visible = false
                    else
                        frame.Visible = true
                        frame.Size = UDim2.new(0, 0, 0, 0)
                        TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 480)}):Play()
                    end
                end
            end
        end
    end

    -- Click TP
    if not gp and State.ClickTP.Active and input.KeyCode == State.ClickTP.Key then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)