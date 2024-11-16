-- made by chatgpt
local ESPSettings = _G.ESPSettings or {}  -- Accept settings passed from the client
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Function to create ESP
local function createESP(player)
    if player == Players.LocalPlayer then return end

    local function applyESP(character)
        if character:FindFirstChild("Head") and not character:FindFirstChild("ESPGui") then
            -- Create BillboardGui
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPGui"
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(4, 0, 1.5, 0)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Adornee = character:FindFirstChild("Head")

            -- Name Label
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = ESPSettings.NameColor or Color3.fromRGB(0, 255, 0)
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.Text = player.Name
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextSize = ESPSettings.TextSize or 16
            nameLabel.Parent = billboard

            -- Health Label
            local healthLabel = Instance.new("TextLabel")
            healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
            healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
            healthLabel.BackgroundTransparency = 1
            healthLabel.TextColor3 = ESPSettings.HealthColor or Color3.fromRGB(255, 0, 0)
            healthLabel.TextStrokeTransparency = 0.5
            healthLabel.Text = "Health: N/A"
            healthLabel.Font = Enum.Font.SourceSansBold
            healthLabel.TextSize = ESPSettings.TextSize or 16
            healthLabel.Parent = billboard

            billboard.Parent = character

            -- Update health dynamically
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                RunService.RenderStepped:Connect(function()
                    if character.Parent and humanoid.Health > 0 then
                        healthLabel.Text = string.format("Health: %.0f", humanoid.Health)
                    else
                        billboard:Destroy()
                    end
                end)
            end
        end
    end

    if player.Character then
        applyESP(player.Character)
    end

    player.CharacterAdded:Connect(function(character)
        applyESP(character)
    end)
end

-- Remove ESP
local function removeESP(player)
    if player.Character then
        local espGui = player.Character:FindFirstChild("ESPGui")
        if espGui then
            espGui:Destroy()
        end
    end
end

-- Apply ESP
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)
