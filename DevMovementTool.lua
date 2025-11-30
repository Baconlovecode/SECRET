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
    Bypass = { Active = false } -- Anti-Rubberband
}

-- // VISUALIZER & REACH // --
local rangeVisualizer = nil
local originalSizes = {}
local espFolder = Instance.new("Folder", playerGui)
espFolder.Name = "BCODE_ESP"

-- // UI LIBRARY // --
local Library = {}

function Library:Create(titleText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BCODE_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    
    -- Attempt to parent to CoreGui (for overlaying Roblox menu), fallback to PlayerGui
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ScreenGui.Parent = playerGui
    end
    
    -- Main Frame with Scale Animation
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
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BackgroundColor3 = UI_THEME.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    -- Sidebar Gradient
    local SidebarGrad = Instance.new("UIGradient")
    SidebarGrad.Rotation = 45
    SidebarGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    }
    SidebarGrad.Parent = Sidebar
    
    -- Fix Sidebar Corner
    local SidebarFix = Instance.new("Frame")
    SidebarFix.Size = UDim2.new(0, 10, 1, 0)
    SidebarFix.Position = UDim2.new(1, -10, 0, 0)
    SidebarFix.BackgroundColor3 = Color3.fromRGB(12, 12, 18) 
    SidebarFix.BorderSizePixel = 0
    SidebarFix.Parent = Sidebar
    
    -- Window Controls (Mac Style)
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
    
    -- Red (Close/Hide)
    CreateControlBtn(Color3.fromRGB(255, 95, 87), 0, function()
        MainFrame.Visible = false
    end)
    
    -- Yellow (Minimize)
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
    
    -- Green (Maximize)
    local maximized = false
    CreateControlBtn(Color3.fromRGB(39, 201, 63), 40, function()
        maximized = not maximized
        if maximized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 800, 0, 600)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 480)}):Play()
        end
    end)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "BCODE HUB"
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 24
    Title.TextColor3 = UI_THEME.Accent
    Title.Size = UDim2.new(1, -30, 0, 40)
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
    SubTitle.Position = UDim2.new(0, 2, 0, 28)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.Parent = Title
    
    -- Tab Container
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
    
    -- Content Area
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
            
            -- Animate Page Entry
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
                local ripple = Instance.new("Frame")
                ripple.BackgroundColor3 = Color3.new(1,1,1)
                ripple.BackgroundTransparency = 0.8
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.Parent = BtnFrame
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = ripple
                
                TweenService:Create(ripple, TweenInfo.new(0.4), {Size = UDim2.new(1.2, 0, 2, 0), BackgroundTransparency = 1}):Play()
                task.delay(0.4, function() ripple:Destroy() end)
                
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
        
        return TabObj
    end
    
    return Window
end

-- // MAIN LOGIC // --

local Window = Library:Create("BCODE")

-- 1. HOME TAB
local Home = Window:Tab("Home", "rbxassetid://7733960981")
Home:Section("Main")
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

-- 2. MOVEMENT TAB
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
Movement:Toggle("Anti-Rubberband", false, function(v) State.Bypass.Active = v end)

Movement:Section("Teleport")
Movement:Input("Click TP Key (e.g. T)", "T", function(v)
    local s, k = pcall(function() return Enum.KeyCode[v:upper()] end)
    if s and k then State.ClickTP.Key = k end
end)
Movement:Toggle("Enable Click TP", false, function(v) State.ClickTP.Active = v end)

-- 3. COMBAT TAB
local Combat = Window:Tab("Combat", "rbxassetid://7733965184")
Combat:Section("Kill Aura")
Combat:Toggle("Kill Aura (Reach)", false, function(v) State.KillAura.Active = v end)
Combat:Slider("Aura Range", 5, 50, 15, function(v) 
    State.KillAura.Range = v 
    if rangeVisualizer then rangeVisualizer.Size = Vector3.new(v*2, v*2, v*2) end
end)
Combat:Toggle("Team Check", false, function(v) State.KillAura.TeamCheck = v end)

Combat:Section("Aim & Stun")
Combat:Toggle("No Stun", false, function(v) State.NoStun.Active = v end)

Combat:Section("God Mode")
Combat:Toggle("God Mode (Anti-Touch)", false, function(v) State.GodMode.Active = v end)

-- 4. VISUALS TAB
local Visuals = Window:Tab("Visuals", "rbxassetid://7733965639")
Visuals:Section("Visuals")
Visuals:Toggle("Show Aura Range", false, function(v) 
    State.KillAura.Visualizer = v 
    if v then
        if not rangeVisualizer then
            rangeVisualizer = Instance.new("Part")
            rangeVisualizer.Name = "AuraVisualizer"
            rangeVisualizer.Shape = Enum.PartType.Ball
            rangeVisualizer.Color = Color3.fromRGB(255, 0, 0)
            rangeVisualizer.Material = Enum.Material.ForceField
            rangeVisualizer.Transparency = 0.8
            rangeVisualizer.CanCollide = false
            rangeVisualizer.CanTouch = false
            rangeVisualizer.CanQuery = false
            rangeVisualizer.Anchored = true
            rangeVisualizer.CastShadow = false
            rangeVisualizer.Size = Vector3.new(State.KillAura.Range*2, State.KillAura.Range*2, State.KillAura.Range*2)
            rangeVisualizer.Parent = Workspace
        end
    else
        if rangeVisualizer then rangeVisualizer:Destroy() rangeVisualizer = nil end
    end
end)
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

-- // LOGIC LOOPS // --

-- ESP Loop
task.spawn(function()
    while task.wait(1) do
        if State.ESP.Active then
            espFolder:ClearAllChildren()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    -- Team Check
                    if State.ESP.TeamCheck and p.Team == player.Team then
                        continue
                    end
                    
                    -- Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = p.Character
                    highlight.FillColor = p.TeamColor.Color
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = p.TeamColor.Color -- Match Outline to Team
                    highlight.OutlineTransparency = 0
                    highlight.Parent = espFolder
                    
                    -- Name
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

-- Anti-AFK
player.Idled:Connect(function()
    if State.AntiAFK.Active then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Speed & Bypass
RunService.Heartbeat:Connect(function(dt)
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        
        -- Speed Logic
        if State.Speed.Active and hum and root and hum.MoveDirection.Magnitude > 0 then
            hum.WalkSpeed = 16 
            local extraSpeed = State.Speed.Value - 16
            if extraSpeed > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * extraSpeed * dt)
                
                -- Anti-Rubberband (Velocity Spoofing)
                if State.Bypass.Active then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Trick server into thinking we are still
                end
            end
        end
        
        -- Fly Bypass
        if State.Fly.Active and State.Bypass.Active and root then
             root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
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
            
            -- Remove Stun Effects
            for _, child in pairs(player.Character:GetChildren()) do
                if child.Name:lower():find("stun") then child:Destroy() end
            end
            for attr, _ in pairs(player.Character:GetAttributes()) do
                if attr:lower():find("stun") then player.Character:SetAttribute(attr, false) end
            end
        end
    end
end)

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
            hum.JumpPower = 50
            task.delay(0.05, function()
                if hum.FloorMaterial ~= Enum.Material.Air or State.InfJump.Active then
                    local currentVel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(currentVel.X, State.Jump.Value, currentVel.Z)
                end
            end)
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

-- Kill Aura
task.spawn(function()
    while task.wait(0.01) do
        if State.KillAura.Active and player.Character then
            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
            
            -- Visualizer Update
            if rangeVisualizer and myRoot then
                if rangeVisualizer.Parent ~= Workspace then rangeVisualizer.Parent = Workspace end
                rangeVisualizer.CFrame = myRoot.CFrame
            end

            if myRoot then
                local tool = player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        if not originalSizes[handle] then originalSizes[handle] = handle.Size end
                        handle.Size = Vector3.new(State.KillAura.Range*2, State.KillAura.Range*2, State.KillAura.Range*2)
                        handle.CanCollide = false
                        handle.Transparency = 0.8
                        handle.Massless = true
                    end
                    
                    for _, other in pairs(Players:GetPlayers()) do
                        if other ~= player and other.Character then
                            if State.KillAura.TeamCheck and other.Team == player.Team then continue end
                            
                            local oRoot = other.Character:FindFirstChild("HumanoidRootPart")
                            local oHum = other.Character:FindFirstChild("Humanoid")
                            if oRoot and oHum and oHum.Health > 0 then
                                if (oRoot.Position - myRoot.Position).Magnitude < State.KillAura.Range then
                                    tool:Activate()
                                    tool.Enabled = true
                                end
                            end
                        end
                    end
                end
            end
        else
            -- Restore Handles
            for handle, size in pairs(originalSizes) do
                if handle and handle.Parent then
                    handle.Size = size
                    handle.CanCollide = true
                    handle.Transparency = 0
                end
            end
            table.clear(originalSizes)
        end
    end
end)

-- God Mode
RunService.Stepped:Connect(function()
    if State.GodMode.Active then
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.Health = hum.MaxHealth 
                hum.BreakJointsOnDeath = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
            
            -- Custom Health/KO System Bypass
            for _, child in pairs(player.Character:GetChildren()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("DoubleConstrainedValue") then
                    if string.match(child.Name:lower(), "health") or string.match(child.Name:lower(), "hp") then
                        child.Value = 9e9 -- Force Max
                    elseif string.match(child.Name:lower(), "down") or string.match(child.Name:lower(), "ko") or string.match(child.Name:lower(), "knock") then
                        child.Value = 0 -- Force Up
                    end
                elseif child:IsA("BoolValue") then
                    if string.match(child.Name:lower(), "dead") or string.match(child.Name:lower(), "down") or string.match(child.Name:lower(), "ko") or string.match(child.Name:lower(), "knock") then
                        child.Value = false -- Force Alive
                    end
                end
            end
            
            -- Attribute Bypass
            for attr, val in pairs(player.Character:GetAttributes()) do
                if string.match(attr:lower(), "down") or string.match(attr:lower(), "ko") or string.match(attr:lower(), "knock") then
                    player.Character:SetAttribute(attr, false)
                elseif string.match(attr:lower(), "health") or string.match(attr:lower(), "hp") then
                    if type(val) == "number" then
                        player.Character:SetAttribute(attr, 100) -- Try to keep it high
                    end
                end
            end
        end
        
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

-- Click TP & Toggle Fix
UserInputService.InputBegan:Connect(function(input, gp)
    -- Toggle UI (Priority High)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        local gui = playerGui:FindFirstChild("BCODE_UI")
        if gui then
            -- Find MainFrame regardless of parent (CoreGui or PlayerGui)
            local frame = gui:FindFirstChild("MainFrame")
            if frame then
                if frame.Visible then
                    -- Close Animation
                    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    task.wait(0.3)
                    frame.Visible = false
                else
                    -- Open Animation
                    frame.Visible = true
                    frame.Size = UDim2.new(0, 0, 0, 0)
                    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 680, 0, 480)}):Play()
                end
            end
        end
    end

    if not gp and State.ClickTP.Active and input.KeyCode == State.ClickTP.Key then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)
