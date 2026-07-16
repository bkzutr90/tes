local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [UI BUILDER]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 450); MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35); MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 5)

-- [STATE DATA]
local States = { Fly = false, FlySpeed = 50, NoClip = false, Nempel = nil, Grab = nil }

local function createInput(text, default, callback)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(1, -10, 0, 30); box.PlaceholderText = text; box.Text = tostring(default)
    box.FocusLost:Connect(function() callback(tonumber(box.Text)) end)
end

-- [CORE LOGIC]
-- FLY (Custom Speed)
RunService.RenderStepped:Connect(function()
    if States.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * States.FlySpeed
    end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if States.NoClip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- NEMPEL (Backend)
RunService.RenderStepped:Connect(function()
    if States.Nempel and States.Nempel.Character then
        local targetHrp = States.Nempel.Character:FindFirstChild("HumanoidRootPart")
        if targetHrp then LocalPlayer.Character.HumanoidRootPart.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2) end
    end
end)

-- [UI ELEMENTS]
local function addButton(text, func)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, -10, 0, 30); btn.Text = text
    btn.MouseButton1Click:Connect(func)
end

addButton("Toggle Fly", function() States.Fly = not States.Fly end)
createInput("Fly Speed", 50, function(v) States.FlySpeed = v end)
addButton("Toggle NoClip", function() States.NoClip = not States.NoClip end)
addButton("Speed: 16", function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end)
createInput("Set Speed", 16, function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end)

-- DROPDOWN PLAYER
local Dropdown = Instance.new("TextButton", MainFrame); Dropdown.Text = "Pilih Player (Klik)"
Dropdown.Size = UDim2.new(1, -10, 0, 30)
Dropdown.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            addButton("TP ke " .. p.Name, function() 
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame 
            end)
            addButton("Nempel " .. p.Name, function() States.Nempel = p end)
        end
    end
end)

addButton("Stop Nempel/Grab", function() States.Nempel = nil; States.Grab = nil end)

-- GRAB (Tali)
addButton("Grab (Klik Player)", function()
    local conn; conn = Mouse.Button1Down:Connect(function()
        local target = Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid")
        if target then
            States.Grab = target.Parent
            local rope = Instance.new("RopeConstraint", LocalPlayer.Character.HumanoidRootPart)
            rope.Attachment0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            rope.Attachment1 = Instance.new("Attachment", target.Parent.HumanoidRootPart)
            rope.Visible = true; rope.Length = 5
        end
        conn:Disconnect()
    end)
end)
