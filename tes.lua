--[[ 
    Universal Admin Panel - Full Features
    Compatible with Delta/Mobile Executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 400)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Scrollable

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 5)

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
ToggleBtn.Text = "Toggle Menu"
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Helper Button
local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- [FITUR LOGIC]
-- 1. Fly
local fly = false
createButton("Fly (Toggle)", function()
    fly = not fly
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if fly then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "BF"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.zero
    else
        if hrp:FindFirstChild("BF") then hrp.BF:Destroy() end
    end
end)

-- 2. NoClip
local noclip = false
createButton("NoClip (Toggle)", function() noclip = not noclip end)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- 3. Speed Boost
createButton("Speed: 100", function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)

-- 4. Teleport ke Player (Pilih player terdekat)
createButton("TP ke Player", function()
    local target = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then target = plr.Character; break end
    end
    if target then LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame end
end)

-- 5. Nempel (Bring/Anchor)
createButton("Nempel ke Player", function()
    local target = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then target = plr.Character; break end
    end
    RunService.RenderStepped:Connect(function()
        if target and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
        end
    end)
end)

-- 6. Carry/Grab (Menggunakan AlignPosition jika tersedia, ini versi simpel)
createButton("Carry Player (Touch)", function()
    local Mouse = LocalPlayer:GetMouse()
    Mouse.Button1Down:Connect(function()
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            local target = Mouse.Target.Parent.HumanoidRootPart
            local weld = Instance.new("WeldConstraint", LocalPlayer.Character.HumanoidRootPart)
            weld.Part0 = LocalPlayer.Character.HumanoidRootPart
            weld.Part1 = target
        end
    end)
end)

-- 7. Reset
createButton("Reset Karakter", function() LocalPlayer.Character.Humanoid.Health = 0 end)
