local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [UI SETUP]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 450)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.CanvasSize = UDim2.new(0,0,3,0)
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 5)

-- [FUNGSI UI]
local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(1, -10, 0, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.FocusLost:Connect(function(enter) if enter then callback(tonumber(box.Text)) end end)
end

-- [LOGIC FITUR]
local FlySpeed = 50
local Flying = false

-- Fly (Dengan kontrol arah kamera)
local function startFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local bv = Instance.new("BodyVelocity", hrp); bv.Name = "FlyV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    local conn = RunService.RenderStepped:Connect(function()
        if not Flying then bv:Destroy(); return end
        local cam = workspace.CurrentCamera.CFrame.LookVector
        local move = Vector3.new(0,0,0)
        -- Input sederhana (bisa diganti dengan deteksi WASD)
        bv.Velocity = cam * FlySpeed
    end)
end

-- UI Controls
local ToggleBtn = Instance.new("TextButton", ScreenGui); ToggleBtn.Size = UDim2.new(0, 100, 0, 40); ToggleBtn.Text = "Menu"
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Create Buttons
local function createButton(text, func)
    local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(1, -10, 0, 40); b.Text = text; b.MouseButton1Click:Connect(func)
end

createInput("Set Speed", function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end)
createInput("Set JumpPower", function(v) LocalPlayer.Character.Humanoid.JumpPower = v end)

createButton("Toggle Fly", function() 
    Flying = not Flying
    if Flying then startFly() end
end)

local Noc = false
createButton("Toggle NoClip", function()
    Noc = not Noc
    RunService.Stepped:Connect(function()
        if Noc and LocalPlayer.Character then
            for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)
end)

createButton("TP ke Player Terdekat", function()
    local closest, dist = nil, math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local d = (p.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then closest = p.Character; dist = d end
        end
    end
    if closest then LocalPlayer.Character.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame end
end)

createButton("Nempel (Lock)", function()
    local target = Players:GetPlayers()[math.random(2, #Players:GetPlayers())].Character
    local conn; conn = RunService.RenderStepped:Connect(function()
        if target and target:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
        else conn:Disconnect() end
    end)
end)
