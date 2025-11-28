--[[
    DevMovementTool.lua
    
    Instructions:
    1. Create a "LocalScript" in Roblox Studio.
    2. Place it inside "StarterPlayer" -> "StarterPlayerScripts" OR inside "StarterGui".
    3. Paste this code into the script.
    
    Controls:
    - Click "Toggle Speed" to switch between normal (16) and fast (100) speed.
    - Click "Toggle Jump" to switch between normal (50) and high (200) jump power.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local NORMAL_SPEED = 16
local BOOST_SPEED = 100
local NORMAL_JUMP = 50
local BOOST_JUMP = 200

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevMovementGui"
screenGui.ResetOnSpawn = false -- Keep GUI after death
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0.5, -50) -- Left side of screen
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Dev Tools"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- Speed Button
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 30)
speedBtn.Position = UDim2.new(0.05, 0, 0, 35)
speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBtn.Text = "Toggle Speed: OFF"
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Font = Enum.Font.Gotham
speedBtn.Parent = frame

-- Jump Button
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0.9, 0, 0, 30)
jumpBtn.Position = UDim2.new(0.05, 0, 0, 70)
jumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBtn.Text = "Toggle Jump: OFF"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Font = Enum.Font.Gotham
jumpBtn.Parent = frame

-- Logic
local speedActive = false
local jumpActive = false

local function getHumanoid()
    local character = player.Character
    if character then
        return character:FindFirstChild("Humanoid")
    end
    return nil
end

speedBtn.MouseButton1Click:Connect(function()
    local humanoid = getHumanoid()
    if humanoid then
        speedActive = not speedActive
        if speedActive then
            humanoid.WalkSpeed = BOOST_SPEED
            speedBtn.Text = "Toggle Speed: ON"
            speedBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            humanoid.WalkSpeed = NORMAL_SPEED
            speedBtn.Text = "Toggle Speed: OFF"
            speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    local humanoid = getHumanoid()
    if humanoid then
        jumpActive = not jumpActive
        if jumpActive then
            -- Check if UseJumpPower is enabled, otherwise set JumpHeight
            if humanoid.UseJumpPower then
                humanoid.JumpPower = BOOST_JUMP
            else
                humanoid.JumpHeight = BOOST_JUMP / 5 -- Approx conversion
            end
            jumpBtn.Text = "Toggle Jump: ON"
            jumpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            if humanoid.UseJumpPower then
                humanoid.JumpPower = NORMAL_JUMP
            else
                humanoid.JumpHeight = 7.2 -- Default Roblox JumpHeight
            end
            jumpBtn.Text = "Toggle Jump: OFF"
            jumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end)
