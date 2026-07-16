--[[ 
    Professional Universal Admin Panel - V2
    Arsitektur: Modular, Stabil, UI Modern
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [UI BUILDER - MODEREN]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "ADMIN PANEL - ROBLOX"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.TextColor3 = Color3.new(1,1,1)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

local function createToggle(text, callback)
    local frame = Instance.new("Frame", Container); frame.Size = UDim2.new(1, 0, 0, 30); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Text = text; label.Size = UDim2.new(0.6, 0, 1, 0); label.TextColor3 = Color3.new(1,1,1)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.3, 0, 0.8, 0); btn.Position = UDim2.new(0.65, 0, 0.1, 0); btn.Text = "OFF"
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = active and "ON" or "OFF"
        callback(active)
    end)
end

-- [LOGIKA FITUR]

-- 1. FLY
local flyActive = false
local flySpeed = 50
createToggle("Fly", function(val)
    flyActive = val
    if not val then LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity"):Destroy() end
end)

RunService.RenderStepped:Connect(function()
    if flyActive and LocalPlayer.Character then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if not hrp:FindFirstChild("BodyVelocity") then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
        end
        -- Kontrol arah kamera
        local cam = workspace.CurrentCamera
        hrp.BodyVelocity.Velocity = cam.CFrame.LookVector * flySpeed
    end
end)

-- 2. NOCLIP
local noclip = false
createToggle("NoClip", function(val) noclip = val end)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- 3. SPEED & JUMP
local function createInput(text, property)
    local frame = Instance.new("Frame", Container); frame.Size = UDim2.new(1, 0, 0, 30); frame.BackgroundTransparency = 1
    Instance.new("TextLabel", frame).Text = text; Instance.new("TextBox", frame).Position = UDim2.new(0.6, 0, 0, 0)
    frame.TextBox.FocusLost:Connect(function(enter)
        if enter then LocalPlayer.Character.Humanoid[property] = tonumber(frame.TextBox.Text) end
    end)
end
createInput("Speed", "WalkSpeed")
createInput("Jump", "JumpPower")

-- 4. NEMPEL & GRAB
local targetPlayer = nil
createToggle("Nempel ke Player", function(val)
    -- Logika: Cari player terdekat dan kunci ke CFrame belakangnya
    if val then
        local nearest = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then nearest = p.Character end
        end
        targetPlayer = nearest
    else targetPlayer = nil end
end)

RunService.RenderStepped:Connect(function()
    if targetPlayer and targetPlayer:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)

-- Toggle Menu
local OpenBtn = Instance.new("TextButton", ScreenGui); OpenBtn.Text = "Menu"; OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

