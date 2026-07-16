--[[ 
    Universal Admin Panel v2.0
    Status: Modular & Clean
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- 1. Setup Container Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanel_UI"
ScreenGui.Parent = CoreGui -- Delta mendukung CoreGui

-- 2. Toggle Button (Untuk membuka/tutup panel)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Position = UDim2.new(0, 10, 0, 100)
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Text = "MENU"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 3. Main Panel (Panel Utama)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false -- Default disembunyikan
MainFrame.Draggable = true -- Bisa didrag

-- Judul Panel
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ADMIN PANEL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1

-- Layout List agar rapi
local Layout = Instance.new("UIListLayout", MainFrame)
Layout.Padding = UDimConfig.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 4. Fungsi Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- 5. Fungsi Helper Tombol
local function createButton(name, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 6. Implementasi Fitur Dasar
createButton("Toggle Fly", function()
    print("Fly Toggled")
    -- Tambahkan logic fly Anda di sini
end)

createButton("NoClip", function()
    -- Logic NoClip: Loop set CanCollide = false
    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
end)

-- Anti-Delete Protection (Opsional untuk stabilitas)
task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then
            ScreenGui.Parent = CoreGui
        end
    end
end)
