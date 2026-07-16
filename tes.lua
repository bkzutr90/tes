--[[ 
    Advanced Universal Admin Panel
    Arsitektur: Modular, Clean UI, Input-Drivennnn
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer

-- [UI SETUP]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 500)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper untuk Membuat Elemen UI
local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", MainFrame)
    box.Size = UDim2.new(0.9, 0, 0, 35)
    box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
    return box
end

local function createToggle(name, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(toggled)
    end)
end

-- [FITUR UTAMA]

-- 1. Fly dengan Kecepatan Custom
local flySpeed = 50
createInput("Fly Speed (Angka)", function(val) flySpeed = tonumber(val) or 50 end)
createToggle("Fly", function(state)
    if state then
        local bv = Instance.new("BodyVelocity", LP.Character.HumanoidRootPart); bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        RunService.RenderStepped:Connect(function()
            if LP.Character and LP.Character:FindFirstChild("FlyVel") then
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
            end
        end)
    else
        if LP.Character.HumanoidRootPart:FindFirstChild("FlyVel") then LP.Character.HumanoidRootPart.FlyVel:Destroy() end
    end
end)

-- 2. NoClip
createToggle("NoClip", function(state)
    RunService.Stepped:Connect(function()
        if state and LP.Character then
            for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end
    end)
end)

-- 3. Speed & Jump
createInput("WalkSpeed (Angka)", function(val) LP.Character.Humanoid.WalkSpeed = tonumber(val) end)
createInput("JumpPower (Angka)", function(val) LP.Character.Humanoid.UseJumpPower = true; LP.Character.Humanoid.JumpPower = tonumber(val) end)

-- 4. Teleport ke Player (Dropdown Sederhana)
local targetPlayer = nil
local TPBtn = Instance.new("TextButton", MainFrame)
TPBtn.Size = UDim2.new(0.9, 0, 0, 35); TPBtn.Text = "Pilih Target (Klik)"
TPBtn.MouseButton1Click:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP then targetPlayer = plr; TPBtn.Text = "TP ke: " .. plr.Name; break end
    end
end)
TPBtn.MouseButton2Click:Connect(function()
    if targetPlayer then LP.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame end
end)

-- 5. Nempel (Belakang Player)
local stick = false
createToggle("Nempel (Belakang)", function(state)
    stick = state
    RunService.RenderStepped:Connect(function()
        if stick and targetPlayer and targetPlayer.Character then
            LP.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        end
    end)
end)

-- 6. Grab (Tali/Weld)
createToggle("Grab Player (Klik target)", function(state)
    if state then
        LP:GetMouse().Button1Down:Connect(function()
            local target = LP:GetMouse().Target
            if target and target.Parent:FindFirstChild("Humanoid") then
                local weld = Instance.new("Weld", LP.Character.HumanoidRootPart)
                weld.Part0 = LP.Character.HumanoidRootPart
                weld.Part1 = target.Parent.HumanoidRootPart
                weld.Name = "GrabWeld"
            end
        end)
    else
        for _,v in pairs(LP.Character.HumanoidRootPart:GetChildren()) do if v.Name == "GrabWeld" then v:Destroy() end end
    end
end)

-- Toggle Menu
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40); ToggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
ToggleBtn.Text = "UI"; ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
