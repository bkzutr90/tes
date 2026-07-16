--[[ 
    Universal Admin Panel - Full Features
    Compatible with Delta/Mobile Executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables
local flyEnabled = false
local noclipEnabled = false
local speedValue = 16
local jumpValue = 50
local nempelEnabled = false
local grabEnabled = false
local selectedPlayer = nil
local nempelTarget = nil
local grabTarget = nil
local weldConnection = nil
local nempelConnection = nil
local flyConnection = nil
local flyBV = nil
local grabWeld = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanel"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("ScrollingFrame")
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
MainFrame.ScrollBarThickness = 8
MainFrame.Parent = ScreenGui

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Text = "EXAMPLE PANEL - ROBLOX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Toggle Menu Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 100, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -17)
ToggleBtn.Text = "☰ MENU"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui
ToggleBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
    if MainFrame.Visible then
        ToggleBtn.Text = "✕ CLOSE"
    else
        ToggleBtn.Text = "☰ MENU"
    end
end)

-- Helper Functions
local function createSection(text)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -10, 0, 25)
    section.Text = "  " .. text
    section.TextColor3 = Color3.fromRGB(200, 200, 220)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    section.BackgroundTransparency = 0.3
    section.Font = Enum.Font.GothamBold
    section.TextScaled = true
    section.Parent = MainFrame
    return section
end

local function createToggle(text, variable, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0.8, 0)
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        variable = not variable
        if variable then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        if callback then callback(variable) end
    end)
    
    return {btn = btn, get = function() return variable end, set = function(v) 
        variable = v
        if v then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        if callback then callback(v) end
    end}
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = text .. " (" .. default .. ")"
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame
    
    local slider = Instance.new("TextBox")
    slider.Size = UDim2.new(1, -10, 0.4, 0)
    slider.Position = UDim2.new(0, 5, 0.5, 0)
    slider.Text = tostring(default)
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    slider.Font = Enum.Font.Gotham
    slider.TextScaled = true
    slider.Parent = frame
    
    slider.FocusLost:Connect(function()
        local num = tonumber(slider.Text)
        if num then
            num = math.clamp(num, min, max)
            slider.Text = tostring(num)
            label.Text = text .. " (" .. num .. ")"
            if callback then callback(num) end
        else
            slider.Text = tostring(default)
        end
    end)
    
    return {slider = slider, set = function(v)
        v = math.clamp(v, min, max)
        slider.Text = tostring(v)
        label.Text = text .. " (" .. v .. ")"
        if callback then callback(v) end
    end}
end

local function createDropdown(text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.5, 0, 0.9, 0)
    dropdown.Position = UDim2.new(0.5, 0, 0.05, 0)
    dropdown.Text = "Pilih Player..."
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextScaled = true
    dropdown.Parent = frame
    
    local function updateOptions()
        local players = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(players, plr.Name)
            end
        end
        return players
    end
    
    dropdown.MouseButton1Click:Connect(function()
        local players = updateOptions()
        if #players == 0 then
            dropdown.Text = "No Players Available"
            return
        end
        
        -- Create dropdown menu
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(0, 150, 0, #players * 30 + 10)
        menu.Position = UDim2.new(0, dropdown.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, dropdown.AbsolutePosition.Y + 35)
        menu.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        menu.BackgroundTransparency = 0.2
        menu.BorderSizePixel = 0
        menu.Visible = true
        menu.Parent = MainFrame
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = menu
        
        for _, name in pairs(players) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 28)
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            btn.Parent = menu
            
            btn.MouseButton1Click:Connect(function()
                dropdown.Text = name
                if callback then callback(name) end
                menu:Destroy()
            end)
        end
        
        -- Click outside to close
        local function closeMenu()
            if menu then menu:Destroy() end
            UserInputService.InputBegan:Disconnect(closeConnection)
        end
        
        local closeConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = UserInputService:GetMouseLocation()
                if not menu or not menu.AbsolutePosition then closeMenu() return end
                local inside = pos.X >= menu.AbsolutePosition.X and pos.X <= menu.AbsolutePosition.X + menu.AbsoluteSize.X and
                             pos.Y >= menu.AbsolutePosition.Y and pos.Y <= menu.AbsolutePosition.Y + menu.AbsoluteSize.Y
                if not inside then closeMenu() end
            end
        end)
    end)
    
    return dropdown
end

-- Create UI Sections
createSection("MAIN")

-- Fly with speed slider
local flyStatus = createToggle("FLY", false, function(v)
    flyEnabled = v
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flyEnabled then
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not char or not hrp then return end
            local speed = tonumber(flySpeedSlider.slider.Text) or 50
            local bv = hrp:FindFirstChild("FlyBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
            end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Vector3.new(0, 0, -speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir + Vector3.new(0, 0, speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir + Vector3.new(-speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Vector3.new(speed, 0, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, speed * 1.5, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir + Vector3.new(0, -speed * 1.5, 0) end
            bv.Velocity = hrp.CFrame:VectorToWorldSpace(dir)
        end)
    else
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if hrp and hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
    end
end)

local flySpeedSlider = createSlider("Kecepatan Fly", 10, 200, 50, function(v) end)

createSection("PLAYER")
createSection("MOVEMENT")

-- No Clip toggle
local noclipStatus = createToggle("NO CLIP", false, function(v)
    noclipEnabled = v
end)

-- Teleport to Player with dropdown
local function teleportToPlayer(playerName)
    if not playerName or playerName == "" or playerName == "Pilih Player..." then return end
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

createSection("TELEPORT")
local teleportDropdown = createDropdown("TELEPORT TO PLAYER", {}, function(v)
    selectedPlayer = v
    teleportToPlayer(v)
end)

createSection("MISC")

-- Speed slider
local speedSlider = createSlider("SPEED", 10, 200, 16, function(v)
    speedValue = v
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end)

-- Jump slider
local jumpSlider = createSlider("JUMP POWER", 20, 200, 50, function(v)
    jumpValue = v
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end)

-- Nempel ke Player toggle
local nempelStatus = createToggle("NEMPEL KE PLAYER", false, function(v)
    nempelEnabled = v
    if nempelConnection then nempelConnection:Disconnect(); nempelConnection = nil end
    
    if v then
        -- Find target
        local targetPlayer = nil
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                targetPlayer = plr
                break
            end
        end
        
        if targetPlayer then
            nempelTarget = targetPlayer
            nempelConnection = RunService.RenderStepped:Connect(function()
                if not nempelEnabled then return end
                local char = LocalPlayer.Character
                local targetChar = nempelTarget and nempelTarget.Character
                if char and char:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                    -- Nempel di belakang player
                    local targetCFrame = targetChar.HumanoidRootPart.CFrame
                    char.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, 2)
                end
            end)
        else
            nempelStatus.set(false)
        end
    end
end)

-- Grab Player toggle
local grabStatus = createToggle("GRAB PLAYER", false, function(v)
    grabEnabled = v
    if not v then
        if grabWeld then grabWeld:Destroy(); grabWeld = nil end
        if grabConnection then grabConnection:Disconnect(); grabConnection = nil end
        -- Remove release button if exists
        if releaseBtn then releaseBtn:Destroy(); releaseBtn = nil end
        return
    end
    
    -- Find target player
    local targetPlayer = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer = plr
            break
        end
    end
    
    if targetPlayer then
        grabTarget = targetPlayer
        local char = LocalPlayer.Character
        local targetChar = targetPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            -- Create weld constraint (tali)
            grabWeld = Instance.new("WeldConstraint")
            grabWeld.Part0 = char.HumanoidRootPart
            grabWeld.Part1 = targetChar.HumanoidRootPart
            grabWeld.Parent = char.HumanoidRootPart
        end
        
        -- Create release button
        if releaseBtn then releaseBtn:Destroy(); releaseBtn = nil end
        releaseBtn = Instance.new("TextButton")
        releaseBtn.Size = UDim2.new(0, 120, 0, 40)
        releaseBtn.Position = UDim2.new(0.5, -60, 0.85, 0)
        releaseBtn.Text = "🔗 LEPAS"
        releaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        releaseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        releaseBtn.BorderSizePixel = 0
        releaseBtn.Font = Enum.Font.GothamBold
        releaseBtn.TextScaled = true
        releaseBtn.Parent = ScreenGui
        
        releaseBtn.MouseButton1Click:Connect(function()
            grabStatus.set(false)
            if grabWeld then grabWeld:Destroy(); grabWeld = nil end
            if releaseBtn then releaseBtn:Destroy(); releaseBtn = nil end
        end)
    else
        grabStatus.set(false)
    end
end)

createSection("SETTINGS")

-- No Clip handler
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Reset Character
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -10, 0, 30)
resetBtn.Text = "RESET KARAKTER"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextScaled = true
resetBtn.Parent = MainFrame
resetBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = 0
    end
end)

-- Update dropdown options periodically
game:GetService("RunService").Heartbeat:Connect(function()
    if teleportDropdown and teleportDropdown.Parent then
        local players = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(players, plr.Name)
            end
        end
        if #players == 0 then
            teleportDropdown.Text = "No Players"
        end
    end
end)

print("✅ Admin Panel loaded successfully!")
