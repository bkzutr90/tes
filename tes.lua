--[[ 
    Advanced Universal Admin Panel (Stable & Customizable)
    - Gunakan TextBox untuk kustom angka
    - Fly menggunakan Kamera (WASD support)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 5)

-- Fungsi Input Kustom
local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(1, -10, 0, 30)
    box.PlaceholderText = placeholder
    box.FocusLost:Connect(function(enterPressed) if enterPressed then callback(tonumber(box.Text)) end end)
end

-- 1. Fly Dinamis (WASD Support)
local flying = false
local flySpeed = 50
local function toggleFly()
    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        RunService.RenderStepped:Connect(function()
            if not flying then bv:Destroy(); return end
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            bv.Velocity = moveDir * flySpeed
        end)
    end
end

-- 2. NoClip (Stabil)
local noclip = false
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 3. Nempel (Toggleable)
local sticky = false
local stickyTarget = nil
RunService.RenderStepped:Connect(function()
    if sticky and stickyTarget and LocalPlayer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = stickyTarget.CFrame
    end
end)

-- [IMPLEMENTASI UI]
local function createButton(text, cb)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(1, -10, 0, 35); b.Text = text; b.MouseButton1Click:Connect(cb)
end

createButton("Toggle Fly", toggleFly)
createInput("Set Fly Speed (Default 50)", function(val) flySpeed = val or 50 end)
createButton("Toggle NoClip", function() noclip = not noclip end)
createButton("Speed: 100", function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)

createButton("Nempel (Target: First Player)", function()
    sticky = not sticky
    stickyTarget = Players:GetPlayers()[2].Character.HumanoidRootPart -- Contoh target player ke-2
end)

-- Toggle Menu
local toggleBtn = Instance.new("TextButton", ScreenGui)
toggleBtn.Size = UDim2.new(0, 100, 0, 40); toggleBtn.Text = "Menu"
toggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
