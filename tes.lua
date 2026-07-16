local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- [UI BUILDER - SIMPEL ELEGANT]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400); MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); MainFrame.Visible = false; MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "UNIVERSAL PANEL"; Title.Size = UDim2.new(1, 0, 0, 40); Title.TextColor3 = Color3.new(1,1,1)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -40); Container.Position = UDim2.new(0, 0, 0, 40)
Container.BackgroundTransparency = 1

-- [ENGINE LOGIC]
local Engine = { Flying = false, Noclip = false, Following = nil, Speed = 16, Jump = 50 }

-- FLY ENGINE
local function ToggleFly(val)
    Engine.Flying = val
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if val then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.zero
        local bg = Instance.new("BodyGyro", hrp); bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame
    else
        if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    end
end

-- NOCLIP ENGINE
RunService.Stepped:Connect(function()
    if Engine.Noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
    end
end)

-- [KOMPONEN UI GENERATOR]
local function addToggle(name, callback)
    local btn = Instance.new("TextButton", Container); btn.Size = UDim2.new(1, -10, 0, 40); btn.Text = name
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    Instance.new("UIListLayout", Container)
end

-- [IMPLEMENTASI FITUR SESUAI PERMINTAAN]
addToggle("Fly: OFF", function(btn)
    Engine.Flying = not Engine.Flying
    ToggleFly(Engine.Flying)
    btn.Text = "Fly: " .. (Engine.Flying and "ON" or "OFF")
end)

addToggle("NoClip: OFF", function(btn)
    Engine.Noclip = not Engine.Noclip
    btn.Text = "NoClip: " .. (Engine.Noclip and "ON" or "OFF")
end)

addToggle("Nempel Belakang Player", function()
    local target = Players:GetPlayers()[2] -- Ambil player pertama selain diri sendiri
    if target and target.Character then
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not Engine.Following then connection:Disconnect(); return end
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end)
        Engine.Following = connection
    end
end)

addToggle("LEPAS SEMUA (Stop)", function()
    Engine.Flying = false; ToggleFly(false)
    Engine.Noclip = false; Engine.Following = nil
    LocalPlayer.Character.Humanoid.WalkSpeed = 16
end)

-- Toggle Menu
local OpenBtn = Instance.new("TextButton", ScreenGui); OpenBtn.Text = "OPEN"
OpenBtn.Size = UDim2.new(0, 60, 0, 60); OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
