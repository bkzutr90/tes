local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 1. Membuat Container Utama
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AdminPanelUI"
ScreenGui.ResetOnSpawn = false

-- 2. Membuat Frame Utama (Panel)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Mulai dalam keadaan tertutup
MainFrame.Active = true
MainFrame.Draggable = true -- Membuat panel bisa di-drag

-- Menambahkan sedikit desain agar tidak polos
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- 3. Membuat Tombol Toggle (Untuk membuka/menutup panel)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Text = "Toggle Menu"
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.FontSize = Enum.FontSize.Size18

local ToggleCorner = Instance.new("UICorner", ToggleButton)
ToggleCorner.CornerRadius = UDim.new(0, 8)

-- Fungsi Toggle
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 4. Contoh Menambahkan Konten di dalam Frame
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "ADMIN PANEL"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Bold

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Text = "Toggle Fly"
FlyButton.Size = UDim2.new(0.8, 0, 0, 40)
FlyButton.Position = UDim2.new(0.1, 0, 0.2, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FlyButton.TextColor3 = Color3.new(1, 1, 1)

-- Logika Fly Sederhana
local Flying = false
FlyButton.MouseButton1Click:Connect(function()
    Flying = not Flying
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        if Flying then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVelocity"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        else
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        end
    end
end)

print("Admin Panel Berhasil Dimuat!")
