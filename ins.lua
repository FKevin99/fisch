-- Services
local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- Player
local localplayer = players.LocalPlayer
local playergui = localplayer:WaitForChild("PlayerGui")

-- Variables
local autoFishingEnabled = false
local shakeSpeed = 0.1 -- Mengurangi kecepatan shake agar tidak terlalu cepat

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingUI"
screenGui.Parent = playergui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Fishing Bot"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local autoFishingCheckbox = Instance.new("TextButton")
autoFishingCheckbox.Text = "Auto Fishing: OFF"
autoFishingCheckbox.Size = UDim2.new(1, -20, 0, 40)
autoFishingCheckbox.Position = UDim2.new(0, 10, 0, 40)
autoFishingCheckbox.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
autoFishingCheckbox.TextColor3 = Color3.new(1, 1, 1)
autoFishingCheckbox.Font = Enum.Font.SourceSans
autoFishingCheckbox.TextSize = 16
autoFishingCheckbox.Parent = frame

-- Functions for Fishing
local function findRod()
    local character = localplayer.Character
    if not character then return nil end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("rod") or tool.Name:find("Rod")) then
            return tool
        end
    end
    return nil
end

local function castRod()
    local rod = findRod()
    if rod then
        local args = { [1] = 100, [2] = 1 }
        rod.events.cast:FireServer(unpack(args))
    end
end

local function shake()
    local shake_ui = playergui:FindFirstChild("shakeui")
    if shake_ui then
        local safezone = shake_ui:FindFirstChild("safezone")
        local button = safezone and safezone:FindFirstChild("button")

        if button and button.Visible then
            -- Cek apakah button benar-benar ada
            local x = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
            local y = button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
            local vim = game:GetService("VirtualInputManager")
            -- Kirim event klik mouse untuk shake
            vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
            vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end
end

local function reelIn()
    local reel_ui = playergui:FindFirstChild("reel")
    if reel_ui then
        local reel_bar = reel_ui:FindFirstChild("bar")
        if reel_bar then
            -- Langsung menyelesaikan reel tanpa interaksi manual
            replicated_storage.events.reelfinished:FireServer(100, true)
        end
    end
end

-- Auto Fishing Logic
spawn(function()
    while task.wait(shakeSpeed) do
        if autoFishingEnabled then
            local rod = findRod()
            if rod then
                castRod()
                shake() -- Shake sangat cepat
                reelIn() -- Reel instan
            end
        end
    end
end)

-- Fungsi untuk menangani klik pada checkbox
if game:GetService("UserInputService").TouchEnabled then
    -- Jika pada perangkat mobile, gunakan InputBegan
    autoFishingCheckbox.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            autoFishingEnabled = not autoFishingEnabled
            autoFishingCheckbox.Text = autoFishingEnabled and "Auto Fishing: ON" or "Auto Fishing: OFF"
            autoFishingCheckbox.BackgroundColor3 = autoFishingEnabled and Color3.new(0, 0.6, 0) or Color3.new(0.3, 0.3, 0.3)
        end
    end)
else
    -- Jika pada PC, gunakan MouseButton1Click untuk klik mouse
    autoFishingCheckbox.MouseButton1Click:Connect(function()
        autoFishingEnabled = not autoFishingEnabled
        autoFishingCheckbox.Text = autoFishingEnabled and "Auto Fishing: ON" or "Auto Fishing: OFF"
        autoFishingCheckbox.BackgroundColor3 = autoFishingEnabled and Color3.new(0, 0.6, 0) or Color3.new(0.3, 0.3, 0.3)
    end)
end
