--[[ 
    Advanced Universal Admin Panel
    Fitur: Fly(w/ Speed), NoClip, Teleport (Dropdown), Speed/Jump Modifier, Sticky/Grab
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local LP_Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "AdminPanel"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

-- Fungsi Helper UI
local function createToggle(text, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Text = text; label.Size = UDim2.new(0.6, 0, 1, 0); label.TextColor3 = Color3.new(1,1,1)
    local btn = Instance.new("TextButton", frame); btn.Position = UDim2.new(0.7, 0, 0.1, 0); btn.Size = UDim2.new(0.2, 0, 0.8, 0); btn.Text = "OFF"
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

local function createInput(text, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, 0, 0, 40); frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame); label.Text = text; label.Size = UDim2.new(0.6, 0, 1, 0); label.TextColor3 = Color3.new(1,1,1)
    local box = Instance.new("TextBox", frame); box.Position = UDim2.new(0.7, 0, 0.1, 0); box.Size = UDim2.new(0.25, 0, 0.8, 0); box.PlaceholderText = "..."
    box.FocusLost:Connect(function() callback(tonumber(box.Text) or 0) end)
end

-- [LOGIC FITUR]
local FlySpeed = 50
local FlyActive = false

-- Fly Logic
RunService.RenderStepped:Connect(function()
    if FlyActive and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.Velocity = hrp.CFrame.LookVector * (FlySpeed * 2)
    end
end)

createToggle("Fly", function(on) FlyActive = on end)
createInput("Fly Speed", function(val) FlySpeed = val end)

-- NoClip
local NoClipActive = false
RunService.Stepped:Connect(function()
    if NoClipActive and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)
createToggle("NoClip", function(on) NoClipActive = on end)

-- Speed & Jump
createInput("Set Speed", function(val) LocalPlayer.Character.Humanoid.WalkSpeed = val end)
createInput("Set Jump", function(val) LocalPlayer.Character.Humanoid.JumpPower = val end)

-- Nempel (Sticky)
local StickyTarget = nil
createToggle("Nempel ke Player", function(on)
    StickyTarget = on and Players:GetPlayers()[math.random(1, #Players:GetPlayers())] or nil
end)

RunService.Heartbeat:Connect(function()
    if StickyTarget and StickyTarget.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = StickyTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
    end
end)

-- Tombol Open/Close
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40); ToggleBtn.Text = "OPEN MENU"
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
