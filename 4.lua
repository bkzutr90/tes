--[[ 
    Universal Admin Panel - Full Features Fixed
    Compatible with Delta/Mobile Executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local flyEnabled = false
local flySpeed = 50
local noclipEnabled = false
local speedValue = 16
local jumpValue = 50
local teleportTarget = nil
local followTarget = nil
local followEnabled = false
local grabTarget = nil
local grabEnabled = false
local bodyVelocity = nil
local selectedPlayer = nil
local playerList = {}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 220, 0, 450)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 800)

local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Text = "EXAMPLE PANEL - ROBLOX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.BorderSizePixel = 0
Title.LayoutOrder = 0

-- Helper Functions
local function createCategory(text)
    local cat = Instance.new("TextLabel")
    cat.Parent = MainFrame
    cat.Size = UDim2.new(1, -10, 0, 25)
    cat.Text = text
    cat.TextColor3 = Color3.fromRGB(255, 200, 0)
    cat.TextScaled = true
    cat.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    cat.BorderSizePixel = 0
    cat.LayoutOrder = #MainFrame:GetChildren() + 1
    return cat
end

local function createToggle(text, callback, defaultValue)
    local frame = Instance.new("Frame")
    frame.Parent = MainFrame
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = #MainFrame:GetChildren() + 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.25, 0, 0.8, 0)
    btn.Position = UDim2.new(0.72, 0, 0.1, 0)
    btn.Text = defaultValue and "ON" or "OFF"
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.BorderSizePixel = 0

    local state = defaultValue or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        callback(state)
    end)
    return btn, state
end

local function createSlider(text, min, max, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Parent = MainFrame
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = #MainFrame:GetChildren() + 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = text .. " (" .. tostring(defaultValue) .. ")"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1

    local slider = Instance.new("TextBox")
    slider.Parent = frame
    slider.Size = UDim2.new(1, -10, 0.4, 0)
    slider.Position = UDim2.new(0, 5, 0.6, 0)
    slider.Text = tostring(defaultValue)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    slider.BorderSizePixel = 0
    slider.ClearTextOnFocus = false

    local currentValue = defaultValue
    slider.FocusLost:Connect(function()
        local num = tonumber(slider.Text)
        if num then
            currentValue = math.clamp(num, min, max)
            slider.Text = tostring(currentValue)
            label.Text = text .. " (" .. tostring(currentValue) .. ")"
            callback(currentValue)
        else
            slider.Text = tostring(currentValue)
        end
    end)
    return slider, currentValue
end

local function createDropdown(text, options, callback)
    local frame = Instance.new("Frame")
    frame.Parent = MainFrame
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.LayoutOrder = #MainFrame:GetChildren() + 1

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1

    local dropdown = Instance.new("TextButton")
    dropdown.Parent = frame
    dropdown.Size = UDim2.new(0.45, 0, 0.8, 0)
    dropdown.Position = UDim2.new(0.52, 0, 0.1, 0)
    dropdown.Text = "Pilih Player..."
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    dropdown.BorderSizePixel = 0
    dropdown.TextScaled = true

    local selectedOption = nil
    dropdown.MouseButton1Click:Connect(function()
        local playerNames = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        
        if #playerNames == 0 then
            dropdown.Text = "Tidak ada player"
            return
        end
        
        -- Simple selection through cycling
        local currentIndex = 1
        for i, name in pairs(playerNames) do
            if name == dropdown.Text then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #playerNames + 1
        dropdown.Text = playerNames[currentIndex]
        selectedOption = playerNames[currentIndex]
        callback(selectedOption)
    end)
    return dropdown, selectedOption
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextScaled = true
    btn.LayoutOrder = #MainFrame:GetChildren() + 1
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Toggle Menu Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 120, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -20)
ToggleBtn.Text = "TOGGLE MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleBtn.BorderSizePixel = 1
ToggleBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
ToggleBtn.TextScaled = true
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- MAIN CATEGORY
createCategory("MAIN")

-- FLY
local flyBtn, flyState = createToggle("FLY", function(state)
    flyEnabled = state
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if state then
            if not hrp:FindFirstChild("BodyVelocity") then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = hrp
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.zero
            end
        else
            if hrp:FindFirstChild("BodyVelocity") then
                hrp.BodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end
    end
end, false)

createSlider("Kecepatan Fly", 1, 200, 50, function(value)
    flySpeed = value
    if flyEnabled and bodyVelocity then
        -- Speed will be applied in RenderStepped
    end
end)

-- NO CLIP
createToggle("NO CLIP", function(state)
    noclipEnabled = state
    if state and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end, false)

-- TELEPORT TO PLAYER
createCategory("PLAYER")
createDropdown("TELEPORT TO PLAYER", {}, function(playerName)
    if playerName then
        local player = Players:FindFirstChild(playerName)
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- MOVEMENT
createCategory("MOVEMENT")
createSlider("SPEED", 0, 200, 16, function(value)
    speedValue = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

createSlider("JUMP POWER", 0, 200, 50, function(value)
    jumpValue = value
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

-- VISUAL
createCategory("VISUAL")
createToggle("NEMPEL KE PLAYER", function(state)
    followEnabled = state
    if not state then
        followTarget = nil
    else
        -- Find first available player
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                followTarget = player.Character
                break
            end
        end
        if not followTarget then
            followEnabled = false
            -- Turn off toggle
        end
    end
end, false)

createToggle("GRAB PLAYER", function(state)
    grabEnabled = state
    if not state then
        grabTarget = nil
        -- Remove any existing welds
        if LocalPlayer.Character then
            for _, weld in pairs(LocalPlayer.Character:GetDescendants()) do
                if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
                    weld:Destroy()
                end
            end
        end
    else
        -- Find player to grab
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                grabTarget = player.Character
                break
            end
        end
        if grabTarget and LocalPlayer.Character then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            weld.Part1 = grabTarget:FindFirstChild("HumanoidRootPart")
            weld.Parent = LocalPlayer.Character
        end
    end
end, false)

-- MISC
createCategory("MISC")
createButton("LEPAS", function()
    -- Release grab
    grabEnabled = false
    if LocalPlayer.Character then
        for _, weld in pairs(LocalPlayer.Character:GetDescendants()) do
            if weld:IsA("WeldConstraint") or weld:IsA("Weld") then
                weld:Destroy()
            end
        end
    end
    grabTarget = nil
    -- Update toggle button text if needed
end)

-- RunService loops
RunService.RenderStepped:Connect(function()
    -- Fly
    if flyEnabled and bodyVelocity and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and bodyVelocity then
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Vector3.new(0, 0, -flySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction + Vector3.new(0, 0, flySpeed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction + Vector3.new(-flySpeed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Vector3.new(flySpeed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, flySpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction + Vector3.new(0, -flySpeed, 0) end
            
            local cam = workspace.CurrentCamera
            if cam then
                direction = cam.CFrame:VectorToWorldSpace(direction)
                bodyVelocity.Velocity = direction
            end
        end
    end
    
    -- NoClip
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Follow Player
    if followEnabled and followTarget and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = followTarget:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3) -- Position behind player
        end
    end
end)

-- Handle character reset
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Reapply settings
    if speedValue then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speedValue
            humanoid.JumpPower = jumpValue
        end
    end
    
    -- Reapply no clip
    if noclipEnabled then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Reapply grab
    if grabEnabled and grabTarget then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = character:FindFirstChild("HumanoidRootPart")
        weld.Part1 = grabTarget:FindFirstChild("HumanoidRootPart")
        weld.Parent = character
    end
    
    -- Reapply fly
    if flyEnabled then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not hrp:FindFirstChild("BodyVelocity") then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Parent = hrp
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVelocity.Velocity = Vector3.zero
            end
        end
    end
end)

-- Clean up on disconnect
LocalPlayer.OnTeleport:Connect(function()
    ScreenGui:Destroy()
end)

print("Admin Panel Loaded Successfully!")
