--[[ 
    Universal Admin Panel - Full Features (Fixed)
    Compatible with Delta/Mobile Executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local fly = false
local noclip = false
local speedValue = 16
local jumpValue = 50
local isNempel = false
local isGrabbing = false
local grabbedTarget = nil
local nempelTarget = nil
local teleportTarget = nil
local flySpeed = 50
local currentTarget = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanel"
ScreenGui.Parent = game.CoreGui

-- Main Frame (Sesuai contoh gambar)
local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 450)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.Parent = ScreenGui

-- Background Blur
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = game.Lighting

local function updateBlur()
    if MainFrame.Visible then
        Blur.Size = 8
    else
        Blur.Size = 0
    end
end

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "EXAMPLE PANEL - ROBLOX"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- UIListLayout for MainFrame
local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = MainFrame

-- Function to create category header
local function createCategory(text)
    local cat = Instance.new("TextLabel")
    cat.Size = UDim2.new(1, -10, 0, 30)
    cat.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cat.Text = " " .. text
    cat.TextColor3 = Color3.new(1, 1, 1)
    cat.TextXAlignment = Enum.TextXAlignment.Left
    cat.Font = Enum.Font.GothamBold
    cat.Parent = MainFrame
    return cat
end

-- Function to create toggle button with ON/OFF
local function createToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0.25, 0, 1, -5)
    toggle.Position = UDim2.new(0.75, 0, 0, 2.5)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            toggle.Text = "ON"
        else
            toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            toggle.Text = "OFF"
        end
        callback(state)
    end)
    
    return toggle, frame
end

-- Function to create number input
local function createNumberInput(text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.3, 0, 1, -5)
    input.Position = UDim2.new(0.7, 0, 0, 2.5)
    input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    input.Text = tostring(defaultValue)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.Gotham
    input.PlaceholderText = "0"
    input.Parent = frame
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(input.Text)
            if num then
                callback(num)
            end
        end
    end)
    
    return input, frame
end

-- Function to create dropdown
local function createDropdown(text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 1, -5)
    dropdown.Position = UDim2.new(0.5, 0, 0, 2.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdown.Text = "Pilih Player..."
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = frame
    
    local isOpen = false
    local dropdownFrame = nil
    
    dropdown.MouseButton1Click:Connect(function()
        if dropdownFrame then
            dropdownFrame:Destroy()
            dropdownFrame = nil
            isOpen = false
            return
        end
        
        isOpen = true
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(0.5, 0, 0, 150)
        dropdownFrame.Position = UDim2.new(0.5, 0, 1, 0)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdownFrame.Parent = frame
        
        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, 0, 1, 0)
        list.BackgroundTransparency = 1
        list.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
        list.Parent = dropdownFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 2)
        layout.Parent = list
        
        for _, option in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = option
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Gotham
            btn.Parent = list
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Text = option
                callback(option)
                dropdownFrame:Destroy()
                dropdownFrame = nil
                isOpen = false
            end)
        end
    end)
    
    return dropdown, frame
end

-- Function to create action button
local function createActionButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- MAIN CATEGORIES (Sesuai contoh gambar)
createCategory("MAIN")

-- 1. FLY (Toggle + Speed)
local flyToggle, flyFrame = createToggle("FLY", function(state)
    fly = state
    if not state then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("BodyVelocity") then
            hrp.BodyVelocity:Destroy()
        end
    end
end)

-- Fly Speed Input
local flySpeedInput, flySpeedFrame = createNumberInput("FLY SPEED", 50, function(value)
    flySpeed = value
    if fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("BodyVelocity")
            if bv then
                bv.Velocity = Vector3.new(0, flySpeed, 0)
            end
        end
    end
end)

-- 2. NO CLIP (Toggle)
createToggle("NO CLIP", function(state)
    noclip = state
end)

-- 3. PLAYER
createCategory("PLAYER")

-- 4. MOVEMENT
createCategory("MOVEMENT")

-- Speed Input
createNumberInput("SPEED", 16, function(value)
    speedValue = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

-- Jump Power Input
createNumberInput("JUMP POWER", 50, function(value)
    jumpValue = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

-- 5. VISUAL
createCategory("VISUAL")

-- 6. TELEPORT
createCategory("TELEPORT")

-- Teleport Dropdown
local function updatePlayerList()
    local playerList = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
    if #playerList == 0 then
        table.insert(playerList, "Tidak ada player")
    end
    return playerList
end

local tpDropdown, tpFrame = createDropdown("TELEPORT TO PLAYER", updatePlayerList(), function(selected)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name == selected and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
            break
        end
    end
end)

-- 7. MISC
createCategory("MISC")

-- NEMPEL KE PLAYER (Toggle)
local nempelToggle, nempelFrame = createToggle("NEMPEL KE PLAYER", function(state)
    isNempel = state
    if state then
        -- Cari player target
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                nempelTarget = plr.Character
                break
            end
        end
    else
        nempelTarget = nil
    end
end)

-- GRAB PLAYER (Toggle)
local grabToggle, grabFrame = createToggle("GRAB PLAYER", function(state)
    isGrabbing = state
    if state then
        -- Cari player target terdekat
        local closest = nil
        local closestDist = math.huge
        local pos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if pos then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - pos.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = plr.Character
                    end
                end
            end
        end
        if closest then
            grabbedTarget = closest
        end
    else
        grabbedTarget = nil
        -- Hapus semua tali/weld
        if LocalPlayer.Character then
            for _, weld in pairs(LocalPlayer.Character:GetDescendants()) do
                if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
                    weld:Destroy()
                end
            end
        end
    end
end)

-- 8. SETTINGS
createCategory("SETTINGS")

-- Tombol Reset
createActionButton("RESET KARAKTER", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

-- Tombol Toggle Menu (di luar MainFrame)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.Text = "☰ MENU"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    updateBlur()
end)

-- Toggle Menu dengan tombol "X"
local function createCloseButton()
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "✕"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.Parent = MainFrame
    close.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        updateBlur()
    end)
end
createCloseButton()

-- ============ CORE LOGIC ============

-- FLY Logic
RunService.RenderStepped:Connect(function()
    if fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("BodyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "BodyVelocity"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Parent = hrp
            end
            
            local moveDirection = Vector3.zero
            local forward = hrp.CFrame.LookVector
            local right = hrp.CFrame.RightVector
            local up = hrp.CFrame.UpVector
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - forward
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + right
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + up
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - up
            end
            
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * flySpeed
            end
            
            bv.Velocity = moveDirection
        end
    end
end)

-- NO CLIP Logic
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- NEMPEL KE PLAYER Logic
RunService.RenderStepped:Connect(function()
    if isNempel and nempelTarget and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = nempelTarget:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            -- Nempel di belakang player
            local behind = targetHrp.CFrame * CFrame.new(0, 0, -3)
            hrp.CFrame = behind
        end
    end
end)

-- GRAB PLAYER Logic
RunService.RenderStepped:Connect(function()
    if isGrabbing and grabbedTarget and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = grabbedTarget:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            -- Cek apakah weld sudah ada
            local hasWeld = false
            for _, weld in pairs(LocalPlayer.Character:GetDescendants()) do
                if weld:IsA("WeldConstraint") and weld.Part1 == targetHrp then
                    hasWeld = true
                    break
                end
            end
            
            if not hasWeld then
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = hrp
                weld.Part1 = targetHrp
                weld.Parent = LocalPlayer.Character
            end
        end
    end
end)

-- Tombol LEPAS (di layar saat grab aktif)
local releaseBtn = Instance.new("TextButton")
releaseBtn.Size = UDim2.new(0, 100, 0, 40)
releaseBtn.Position = UDim2.new(0.5, -50, 1, -60)
releaseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
releaseBtn.Text = "LEPAS"
releaseBtn.TextColor3 = Color3.new(1, 1, 1)
releaseBtn.Font = Enum.Font.GothamBold
releaseBtn.Visible = false
releaseBtn.Parent = ScreenGui
releaseBtn.MouseButton1Click:Connect(function()
    -- Lepas semua tali
    if LocalPlayer.Character then
        for _, weld in pairs(LocalPlayer.Character:GetDescendants()) do
            if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
                weld:Destroy()
            end
        end
    end
    isGrabbing = false
    grabbedTarget = nil
    releaseBtn.Visible = false
    -- Update toggle state
    if grabToggle then
        grabToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        grabToggle.Text = "OFF"
    end
end)

-- Show release button when grabbing
RunService.RenderStepped:Connect(function()
    if isGrabbing and grabbedTarget then
        releaseBtn.Visible = true
        -- Update posisi tombol di layar
        local camera = game.Workspace.CurrentCamera
        if camera and grabbedTarget:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(grabbedTarget.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            if onScreen then
                releaseBtn.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 60)
            end
        end
    else
        releaseBtn.Visible = false
    end
end)

-- Update player list periodically
task.spawn(function()
    while true do
        task.wait(5)
        if tpDropdown then
            local players = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    table.insert(players, plr.Name)
                end
            end
            if #players == 0 then
                table.insert(players, "Tidak ada player")
            end
            -- Update dropdown options (simplified - recreate dropdown)
            -- For simplicity, we'll just let user reopen dropdown for fresh list
        end
    end
end)

-- Keyboard shortcut: Insert to toggle menu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        updateBlur()
    end
end)

-- Cleanup when character dies
LocalPlayer.CharacterAdded:Connect(function(char)
    -- Reset states
    fly = false
    isNempel = false
    isGrabbing = false
    grabbedTarget = nil
    nempelTarget = nil
    
    -- Reset toggle buttons if they exist
    if flyToggle then
        flyToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        flyToggle.Text = "OFF"
    end
    if nempelToggle then
        nempelToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        nempelToggle.Text = "OFF"
    end
    if grabToggle then
        grabToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        grabToggle.Text = "OFF"
    end
    
    releaseBtn.Visible = false
    
    -- Apply speed and jump settings
    task.wait(0.5)
    if char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speedValue
        char.Humanoid.JumpPower = jumpValue
    end
end)

print("Admin Panel loaded successfully!")
