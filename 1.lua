--[[ 
    Advanced Universal Admin Panel 
    Features: Fly, NoClip, TP Dropdown, Speed/Jump Control, Nempel (Auto-Attach), Grab.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Components
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false
Instance.new("UICorner", MainFrame)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -10, 1, -40); Container.Position = UDim2.new(0, 5, 0, 35)
Container.BackgroundTransparency = 1; Container.CanvasSize = UDim2.new(0,0,2,0)
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40); ToggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
ToggleBtn.Text = "MENU"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Helper Functions
local function createInput(text, placeholder, callback)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(1, 0, 0, 35); box.Text = text; box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50); box.TextColor3 = Color3.new(1,1,1)
    box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
end

-- [STATE DATA]
local States = { Fly = false, NoClip = false, Nempel = false, Target = nil, Flying = nil }

-- 1. Fly dengan BodyVelocity (Directional)
createInput("Fly (Angka Speed)", "Masukkan speed (e.g 50)", function(val)
    States.Fly = not States.Fly
    if States.Fly then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        States.Flying = Instance.new("BodyVelocity", hrp)
        States.Flying.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        RunService.RenderStepped:Connect(function()
            if States.Fly then States.Flying.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * tonumber(val) end
        end)
    else
        if States.Flying then States.Flying:Destroy() end
    end
end)

-- 2. NoClip (Toggle)
createInput("NoClip (On/Off)", "Ketik 'on' atau 'off'", function(val)
    States.NoClip = (val == "on")
end)
RunService.Stepped:Connect(function()
    if States.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- 3. Teleport Dropdown (Pilih Player)
local Dropdown = Instance.new("TextButton", Container)
Dropdown.Text = "Klik utk Pilih Player (TP)"; Dropdown.Size = UDim2.new(1,0,0,35)
Dropdown.MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", Container)
            pBtn.Text = plr.Name; pBtn.Size = UDim2.new(1,0,0,30)
            pBtn.MouseButton1Click:Connect(function()
                LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                pBtn:Destroy()
            end)
        end
    end
end)

-- 4. Speed & Jump
createInput("Speed (Angka)", "Default 16", function(val) LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(val) end)
createInput("Jump Power (Angka)", "Default 50", function(val) LocalPlayer.Character.Humanoid.JumpPower = tonumber(val) end)

-- 5. Nempel (Belakang Player)
createInput("Nempel ke Player", "Ketik nama player", function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        States.Nempel = true
        task.spawn(function()
            while States.Nempel and target.Character do
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait()
            end
        end)
    else
        States.Nempel = false
    end
end)

-- 6. Grab Player (Tali/Weld)
createInput("Grab Player", "Ketik nama player", function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local weld = Instance.new("WeldConstraint", LocalPlayer.Character.HumanoidRootPart)
        weld.Part0 = LocalPlayer.Character.HumanoidRootPart; weld.Part1 = target.Character.HumanoidRootPart
        
        local stopBtn = Instance.new("TextButton", Container)
        stopBtn.Text = "LEPAS GRAB"; stopBtn.BackgroundColor3 = Color3.new(1,0,0)
        stopBtn.MouseButton1Click:Connect(function() weld:Destroy(); stopBtn:Destroy() end)
    end
end)

