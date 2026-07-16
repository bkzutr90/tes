local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [SETUP UI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AdminPanelGui"

-- Frame Utama (Panel)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false -- Awalnya disembunyikan
MainFrame.Active = true
MainFrame.Draggable = true

-- Tombol Buka/Tutup
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.Text = "Toggle Panel"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- UI List Layout agar rapi
local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 5)

-- [FUNGSI FITUR]
local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
end

-- Fly
local flying = false
createButton("Toggle Fly", function()
    flying = not flying
    local char = LocalPlayer.Character
    if flying then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        char.HumanoidRootPart:FindFirstChild("FlyVelocity"):Destroy()
    end
end)

-- NoClip
local noclip = false
createButton("Toggle NoClip", function()
    noclip = not noclip
end)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Teleport ke Mouse
createButton("Teleport to Mouse", function()
    local pos = Mouse.Hit.Position
    LocalPlayer.Character:MoveTo(pos)
end)

-- Speed
createButton("Speed: 50", function()
    LocalPlayer.Character.Humanoid.WalkSpeed = 50
end)

-- Reset
createButton("Reset Character", function()
    LocalPlayer.Character.Humanoid.Health = 0
end)

-- [CATATAN PENTING]
-- Fitur seperti 'Kick' atau 'Carry' sangat bergantung pada RemoteEvent 
-- spesifik di masing-masing game. Anda perlu mencari nama RemoteEvent 
-- tersebut di ReplicatedStorage menggunakan Explorer Delta.
