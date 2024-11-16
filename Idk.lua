-- Configuration settings for ESP
_G.ESPSettings = _G.ESPSettings or {
    FillColor = Color3.fromRGB(255, 0, 0), -- Red
    FillTransparency = 0.5, -- Semi-transparent
    OutlineColor = Color3.fromRGB(0, 0, 0), -- Black
    OutlineTransparency = 0, -- Fully visible outline
    OnlyShowEnemies = false, -- Show only non-teammates
    NameColor = Color3.fromRGB(255, 255, 255), -- White name text
    HealthColor = Color3.fromRGB(0, 255, 0), -- Green health text
    HitboxColor = Color3.fromRGB(0, 0, 255), -- Blue hitbox color
    HitboxTransparency = 0.5, -- Transparent hitbox
    HitboxScale = 1.5, -- Scale factor for the hitbox size (1 = original size)
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Function to check if two players are on the same team
local function arePlayersOnSameTeam(player1, player2)
    return player1.Team == player2.Team
end

-- Function to create ESP for a character
local function createESP(player)
    if player == Players.LocalPlayer then return end -- Skip the local player
    if _G.ESPSettings.OnlyShowEnemies and arePlayersOnSameTeam(player, Players.LocalPlayer) then return end

    local function applyESP(character)
        if character:FindFirstChildOfClass("Highlight") then return end -- Avoid duplicates

        -- Highlight effect
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = _G.ESPSettings.FillColor
        highlight.FillTransparency = _G.ESPSettings.FillTransparency
        highlight.OutlineColor = _G.ESPSettings.OutlineColor
        highlight.OutlineTransparency = _G.ESPSettings.OutlineTransparency
        highlight.Parent = character

        -- Name label above player
        local nameTag = Instance.new("BillboardGui")
        nameTag.Adornee = character:WaitForChild("Head")
        nameTag.Size = UDim2.new(0, 100, 0, 30)
        nameTag.StudsOffset = Vector3.new(0, 3, 0)  -- Position above head
        nameTag.AlwaysOnTop = true
        nameTag.Parent = character
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = _G.ESPSettings.NameColor
        nameLabel.TextStrokeTransparency = 0.8
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Parent = nameTag

        -- Health label to the left and slightly above player
        local healthTag = Instance.new("BillboardGui")
        healthTag.Adornee = character:WaitForChild("Head")
        healthTag.Size = UDim2.new(0, 100, 0, 30)
        healthTag.StudsOffset = Vector3.new(-1.6, 3, 0)  -- Position to the left and slightly above
        healthTag.AlwaysOnTop = true
        healthTag.Parent = character
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Text = "Health: " .. math.floor(player.Character:WaitForChild("Humanoid").Health)
        healthLabel.TextColor3 = _G.ESPSettings.HealthColor
        healthLabel.TextStrokeTransparency = 0.8
        healthLabel.BackgroundTransparency = 1
        healthLabel.Size = UDim2.new(1, 0, 1, 0)
        healthLabel.Parent = healthTag
        
        -- Update health text
        player.Character:WaitForChild("Humanoid").HealthChanged:Connect(function(health)
            healthLabel.Text = "Health: " .. math.floor(health)
        end)

        -- Create hitboxes for key parts (larger hitboxes)
        local function createLargeHitbox(part)
            if part and part:IsA("BasePart") then
                -- Create an invisible part that will surround the character's body parts
                local hitbox = Instance.new("Part")
                hitbox.Size = part.Size * _G.ESPSettings.HitboxScale  -- Scale the hitbox to make it larger
                hitbox.CFrame = part.CFrame
                hitbox.Anchored = true
                hitbox.CanCollide = false
                hitbox.Transparency = _G.ESPSettings.HitboxTransparency
                hitbox.Color = _G.ESPSettings.HitboxColor
                hitbox.Parent = part.Parent  -- Parent to the same model
            end
        end

        -- Apply larger hitboxes to key parts
        local humanoid = character:WaitForChild("Humanoid")
        createLargeHitbox(character:WaitForChild("HumanoidRootPart"))
        createLargeHitbox(character:WaitForChild("Head"))
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" then
                createLargeHitbox(part)
            end
        end
    end

    -- Apply ESP when character is added
    if player.Character then
        applyESP(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        applyESP(character)
    end)
end

-- Add ESP for current players
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

-- Add ESP for players who join later
Players.PlayerAdded:Connect(function(player)
    createESP(player)
    player.CharacterAdded:Connect(function(character)
        createESP(player)
    end)
end)

-- Remove ESP for players who leave (without deleting highlight)
Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        -- Remove all ESP components when a player leaves
        for _, gui in pairs(player.Character:GetChildren()) do
            if gui:IsA("BillboardGui") or gui:IsA("Highlight") then
                gui:Destroy()
            end
        end
    end
end)
