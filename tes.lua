--[[ 
    Universal Admin Panel v1.1 - Fixed & Improved
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui") -- Tempat menyimpan GUI

-- 1. Setup UI Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanel_SG"
ScreenGui.Parent = CoreGui 

local MainFrame = Instance.new("Frame")
MainFrame.Name = "AdminPanel"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175) -- Posisi di tengah layar
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Warna gelap agar elegan
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Default tertutup
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Tambahkan UI Corner (Agar bulat dan modern)
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- 2. Tombol Toggle (Open/Close)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 100, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Toggle Menu"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ToggleButton.Parent = ScreenGui

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 3. Header/Judul Panel
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Universal Admin"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.FontSize = Enum.FontSize.Size24

-- 4. Contoh Fitur di dalam Panel
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 200, 0, 40)
FlyButton.Position = UDim2.new(0, 25, 0, 50)
FlyButton.Text = "Toggle Fly"
FlyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Fungsi Fly yang sudah dioptimasi
local flying = false
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if flying and hrp then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
    else
        if hrp and hrp:FindFirstChild("FlyVelocity") then
            hrp.FlyVelocity:Destroy()
        end
    end
end)

warn("Admin Panel Loaded Successfully")
