--[[ 
    Universal Admin Panel Framework 
    Arsitektur: Modular & Event-Driven
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Komponen UI (Draggable)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- Fitur bawaan untuk drag

-- Fungsi Helper untuk Error Handling
local function safeCall(func, ...)
    local success, err = pcall(func, ...)
    if not success then
        warn("[Framework Error]: " .. tostring(err))
    end
end

-- Modul Utama: Movement
local MovementModule = {
    Speed = 16,
    JumpPower = 50,
    IsFlying = false
}

function MovementModule:ToggleFly()
    self.IsFlying = not self.IsFlying
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if self.IsFlying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    else
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
    end
end

-- Fungsi Automasi Remote (Contoh)
local function getRemote(remoteName)
    -- Mencari remote secara dinamis di ReplicatedStorage
    for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == remoteName then
            return obj
        end
    end
    return nil
end

-- Implementasi Kick (Contoh interaksi server)
local function kickPlayer(targetPlayer)
    local kickRemote = getRemote("KickRemote") -- Sesuaikan dengan nama game
    if kickRemote then
        kickRemote:FireServer(targetPlayer)
    end
end

-- Inisialisasi UI
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Text = "Toggle Panel"
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
