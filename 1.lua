local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

-- Utility: Membuat Input Field
local function createInput(text, default, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Text = text
    label.Size = UDim2.new(0.5, 0, 1, 0)
    local box = Instance.new("TextBox", frame)
    box.Position = UDim2.new(0.5, 0, 0, 0)
    box.Size = UDim2.new(0.5, 0, 1, 0)
    box.Text = tostring(default)
    box.FocusLost:Connect(function() callback(tonumber(box.Text)) end)
end

-- [FITUR UTAMA]

-- 1. FLY (Custom Speed)
local flySpeed = 50
local flying = false
createInput("Fly Speed", 50, function(val) flySpeed = val end)
local flyBtn = Instance.new("TextButton", MainFrame); flyBtn.Text = "Toggle Fly"; flyBtn.Size = UDim2.new(1,0,0,30)
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if flying then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "FlyVelo"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        RunService.RenderStepped:Connect(function() 
            if flying then bv.Velocity = LocalPlayer.Character.Humanoid.MoveDirection * flySpeed end 
        end)
    else
        if hrp:FindFirstChild("FlyVelo") then hrp.FlyVelo:Destroy() end
    end
end)

-- 2. SPEED & JUMP
createInput("WalkSpeed", 16, function(val) LocalPlayer.Character.Humanoid.WalkSpeed = val end)
createInput("JumpPower", 50, function(val) LocalPlayer.Character.Humanoid.JumpPower = val end)

-- 3. NOCLIP
local noclip = false
local noclipBtn = Instance.new("TextButton", MainFrame); noclipBtn.Text = "Toggle NoClip"; noclipBtn.Size = UDim2.new(1,0,0,30)
noclipBtn.MouseButton1Click:Connect(function() noclip = not noclip end)
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- 4. GRAB/CARRY & LEPAS
local grabbed = nil
local grabBtn = Instance.new("TextButton", MainFrame); grabBtn.Text = "Grab Target"; grabBtn.Size = UDim2.new(1,0,0,30)
local stopBtn = Instance.new("TextButton", MainFrame); stopBtn.Text = "LEPAS"; stopBtn.Size = UDim2.new(1,0,0,30); stopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

grabBtn.MouseButton1Click:Connect(function()
    local target = Mouse.Hit -- Logika pemilihan bisa ditambah dropdown
    -- Implementasi Tali (Beam)
    local beam = Instance.new("Beam", LocalPlayer.Character.HumanoidRootPart)
    -- ... (Logika attachment)
end)

stopBtn.MouseButton1Click:Connect(function() 
    -- Logika hapus weld/tali
    if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("Weld") then -- Hapus weld
    end
end)

-- Tombol Buka Tutup
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, 0)
ToggleBtn.Text = "Menu"
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

