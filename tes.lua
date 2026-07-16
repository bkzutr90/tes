-- Versi Lengkap & Stabil
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Setup UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AdminPanel"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 350)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Visible = false
MainFrame.Draggable = true
MainFrame.Active = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ADMIN PANEL PRO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Position = UDim2.new(0, 0, 0, 30)
Container.Size = UDim2.new(1, 0, 1, -30)
Container.CanvasSize = UDim2.new(0, 0, 2, 0) -- Agar bisa discroll
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 5)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 10)
ToggleBtn.Text = "MENU"
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Fungsi Helper
local function addBtn(name, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
end

-- [LOGIKA FITUR]

-- 1. Fly
local flying = false
addBtn("Toggle Fly", function()
    flying = not flying
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "BV"
        bv.Velocity = Vector3.new(0,0,0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        RunService.RenderStepped:Connect(function()
            if flying and hrp then hrp.CFrame = hrp.CFrame + (workspace.CurrentCamera.CFrame.LookVector * 1) end
        end)
    else
        if hrp:FindFirstChild("BV") then hrp.BV:Destroy() end
    end
end)

-- 2. NoClip
local noclip = false
addBtn("Toggle Noclip", function()
    noclip = not noclip
end)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- 3. Teleport to Mouse
addBtn("TP to Mouse", function()
    LocalPlayer.Character:MoveTo(Mouse.Hit.Position)
end)

-- 4. Speed & Jump
addBtn("Speed 100", function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)
addBtn("Jump Power 100", function() LocalPlayer.Character.Humanoid.JumpPower = 100 end)

-- 5. Nempel ke Player (Magnet)
local magnet = false
addBtn("Magnet (Nempel)", function()
    magnet = not magnet
    while magnet do
        task.wait()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- 6. Carry Player (Sederhana)
addBtn("Carry Nearest", function()
    local target = nil
    local dist = 50
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local d = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target = p.Character.HumanoidRootPart end
        end
    end
    if target then target.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2) end
end)
