--[[ 
    Universal Admin Panel - Full Features Fixed
    Compatible with Delta/Mobile Executors
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables for features
local flyEnabled = false
local noclipEnabled = false
local isGrabbing = false
local grabTarget = nil
local isFollowing = false
local followTarget = nil
local flySpeed = 50
local bodyVelocity = nil

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AdminPanel"

-- Main Frame
local MainFrame = Instance.new("ScrollingFrame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 450)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
MainFrame.ScrollBarThickness = 6

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -10, 0, 30)
Title.Position = UDim2.new(0, 5, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "⭐ ADMIN PANEL"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 18
Title.TextStrokeTransparency = 0.5
Title.Font = Enum.Font.GothamBold

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper Functions
local function createSection(text)
    local section = Instance.new("TextLabel", MainFrame)
    section.Size = UDim2.new(1, -10, 0, 25)
    section.BackgroundTransparency = 1
    section.Text = "── " .. text .. " ──"
    section.TextColor3 = Color3.fromRGB(200, 200, 200)
    section.TextSize = 14
    section.Font = Enum.Font.GothamBold
    return section
end

local function createButton(text, callback, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 65)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = color and (color + Color3.fromRGB(20, 20, 20)) or Color3.fromRGB(75, 75, 85)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color or Color3.fromRGB(55, 55, 65)
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(text, variable, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 60, 0, 25)
    toggleBtn.Position = UDim2.new(0.85, -30, 0.5, -12.5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    
    local corner2 = Instance.new("UICorner", toggleBtn)
    corner2.CornerRadius = UDim.new(0, 4)
    
    toggleBtn.MouseButton1Click:Connect(function()
        variable = not variable
        if variable then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            toggleBtn.Text = "ON"
            toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            toggleBtn.Text = "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        if callback then callback(variable) end
    end)
    
    return frame, function() return variable end
end

local function createInput(text, defaultValue, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.35, -10, 0.7, 0)
    input.Position = UDim2.new(0.65, -10, 0.15, 0)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    input.Text = tostring(defaultValue)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.TextSize = 14
    input.Font = Enum.Font.Gotham
    input.BorderSizePixel = 0
    input.ClearTextOnFocus = false
    
    local corner2 = Instance.new("UICorner", input)
    corner2.CornerRadius = UDim.new(0, 4)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(input.Text)
            if val then
                callback(val)
            else
                input.Text = tostring(defaultValue)
            end
        end
    end)
    
    return frame, input
end

local function createDropdown(text, options, callback)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4, -5, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    
    local dropdown = Instance.new("TextButton", frame)
    dropdown.Size = UDim2.new(0.5, -10, 0.7, 0)
    dropdown.Position = UDim2.new(0.5, -10, 0.15, 0)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropdown.Text = "Pilih Player..."
    dropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.BorderSizePixel = 0
    
    local corner2 = Instance.new("UICorner", dropdown)
    corner2.CornerRadius = UDim.new(0, 4)
    
    dropdown.MouseButton1Click:Connect(function()
        local playerList = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(playerList, plr.Name)
            end
        end
        if #playerList == 0 then
            dropdown.Text = "No players found"
            return
        end
        -- Show simple selection (for mobile, use input)
        local selection = Instance.new("TextBox", ScreenGui)
        selection.Size = UDim2.new(0, 200, 0, 40)
        selection.Position = UDim2.new(0.5, -100, 0.5, -20)
        selection.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        selection.Text = "Type player name:"
        selection.TextColor3 = Color3.new(1, 1, 1)
        selection.Font = Enum.Font.Gotham
        selection.TextSize = 14
        selection.BorderSizePixel = 0
        selection.ZIndex = 999
        
        local cornerSel = Instance.new("UICorner", selection)
        cornerSel.CornerRadius = UDim.new(0, 8)
        
        selection.FocusLost:Connect(function()
            local name = selection.Text
            selection:Destroy()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Name:lower():match(name:lower()) and plr ~= LocalPlayer then
                    dropdown.Text = plr.Name
                    callback(plr)
                    return
                end
            end
            dropdown.Text = "Not found"
        end)
        selection:CaptureFocus()
    end)
    
    return frame, dropdown
end

-- Main Features
createSection("MAIN")

-- Fly Toggle + Speed
local flyFrame, flyInput = createInput("FLY SPEED", 50, function(val)
    flySpeed = val
    if flyEnabled and bodyVelocity then
        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
    end
end)

local flyToggleFrame = createToggle("FLY", false, function(state)
    flyEnabled = state
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity", hrp)
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
    else
        if hrp:FindFirstChild("FlyVelocity") then
            hrp.FlyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end)

-- Fly Control
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not flyEnabled or not LocalPlayer.Character then return end
    
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp:FindFirstChild("FlyVelocity") then return end
    
    local bv = hrp.FlyVelocity
    local speed = flySpeed
    
    if input.KeyCode == Enum.KeyCode.W then
        bv.Velocity = hrp.CFrame.LookVector * speed + Vector3.new(0, bv.Velocity.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.S then
        bv.Velocity = -hrp.CFrame.LookVector * speed + Vector3.new(0, bv.Velocity.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.A then
        bv.Velocity = -hrp.CFrame.RightVector * speed + Vector3.new(0, bv.Velocity.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.D then
        bv.Velocity = hrp.CFrame.RightVector * speed + Vector3.new(0, bv.Velocity.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.Space then
        bv.Velocity = Vector3.new(0, speed, 0)
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        bv.Velocity = Vector3.new(0, -speed, 0)
    end
end)

-- NoClip
createToggle("NO CLIP", false, function(state)
    noclipEnabled = state
    if state and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Player Teleport
createSection("PLAYER")

local tpDropdown = createDropdown("TELEPORT TO PLAYER", {}, function(plr)
    if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
    end
end)

-- Movement
createSection("MOVEMENT")

createInput("SPEED", 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

createInput("JUMP POWER", 50, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

-- Visual
createSection("VISUAL")

-- Nempel ke Player
local followState = false
local followFrame = createToggle("NEMPEL KE PLAYER", false, function(state)
    followState = state
    if state then
        -- Find closest player
        local closest = nil
        local closestDist = math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = plr
                end
            end
        end
        followTarget = closest
        if followTarget then
            -- Disable collision
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    else
        followTarget = nil
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Grab Player
local grabState = false
local grabFrame = createToggle("GRAB PLAYER", false, function(state)
    grabState = state
    if state then
        isGrabbing = true
        -- Find closest player
        local closest = nil
        local closestDist = math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = plr
                end
            end
        end
        if closest then
            grabTarget = closest.Character.HumanoidRootPart
            -- Create rope effect
            local rope = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            rope.Name = "GrabRope"
            local rope2 = Instance.new("Attachment", grabTarget)
            rope2.Name = "GrabRopeTarget"
            local constraint = Instance.new("RopeConstraint", LocalPlayer.Character.HumanoidRootPart)
            constraint.Attachment0 = rope
            constraint.Attachment1 = rope2
            constraint.Visible = true
            constraint.Length = 3
            constraint.Thickness = 0.2
            constraint.Color = Color3.fromRGB(255, 215, 0)
            
            -- Create release button
            local releaseBtn = Instance.new("TextButton", ScreenGui)
            releaseBtn.Size = UDim2.new(0, 120, 0, 40)
            releaseBtn.Position = UDim2.new(0.5, -60, 0.9, -20)
            releaseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            releaseBtn.Text = "LEPAS"
            releaseBtn.TextColor3 = Color3.new(1, 1, 1)
            releaseBtn.TextSize = 18
            releaseBtn.Font = Enum.Font.GothamBold
            releaseBtn.BorderSizePixel = 0
            releaseBtn.Name = "ReleaseButton"
            
            local cornerRel = Instance.new("UICorner", releaseBtn)
            cornerRel.CornerRadius = UDim.new(0, 8)
            
            releaseBtn.MouseButton1Click:Connect(function()
                constraint:Destroy()
                rope:Destroy()
                rope2:Destroy()
                releaseBtn:Destroy()
                isGrabbing = false
                grabTarget = nil
                grabState = false
            end)
        end
    else
        isGrabbing = false
        grabTarget = nil
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            if hrp:FindFirstChild("GrabRope") then hrp.GrabRope:Destroy() end
            if hrp:FindFirstChild("RopeConstraint") then hrp.RopeConstraint:Destroy() end
        end
        if ScreenGui:FindFirstChild("ReleaseButton") then
            ScreenGui.ReleaseButton:Destroy()
        end
    end
end)

-- Follow Movement
RunService.RenderStepped:Connect(function()
    if followState and followTarget and followTarget.Character and followTarget.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = followTarget.Character.HumanoidRootPart
        if root and targetRoot then
            -- Position behind player (opposite of their look direction)
            local behind = targetRoot.CFrame * CFrame.new(0, 0, 3)
            root.CFrame = CFrame.new(behind.Position, targetRoot.Position)
        end
    end
end)

-- Grab Movement
RunService.RenderStepped:Connect(function()
    if isGrabbing and grabTarget and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and grabTarget.Parent and grabTarget.Parent:FindFirstChild("Humanoid") then
            -- Pull target towards player
            local direction = (root.Position - grabTarget.Position).Unit
            local distance = (root.Position - grabTarget.Position).Magnitude
            if distance > 2 then
                grabTarget.Velocity = direction * 100
            else
                grabTarget.Velocity = Vector3.zero
            end
        end
    end
end)

-- Misc
createSection("MISC")

createButton("RESET KARAKTER", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end, Color3.fromRGB(200, 50, 50))

-- Toggle Button
local toggleMenuBtn = Instance.new("TextButton", ScreenGui)
toggleMenuBtn.Size = UDim2.new(0, 120, 0, 40)
toggleMenuBtn.Position = UDim2.new(0, 10, 0.5, -20)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
toggleMenuBtn.Text = "⚙️ MENU"
toggleMenuBtn.TextColor3 = Color3.new(1, 1, 1)
toggleMenuBtn.TextSize = 16
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.BorderSizePixel = 0

local cornerMenu = Instance.new("UICorner", toggleMenuBtn)
cornerMenu.CornerRadius = UDim.new(0, 8)

toggleMenuBtn.MouseEnter:Connect(function()
    toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
end)
toggleMenuBtn.MouseLeave:Connect(function()
    toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
end)

toggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

print("✅ Admin Panel Loaded Successfully!")
