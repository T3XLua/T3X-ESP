local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ESP, SpeedHack, JumpHack",
    Icon = 0,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by dizzy",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "dizzy Hub"
    }
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Main Tab (ESP)
local MainTab = Window:CreateTab("ESP", 120763171259943)
local MainSection = MainTab:CreateSection("Enabled")

Rayfield:Notify({
    Title = "Executed",
    Content = "Have Fun!",
    Duration = 3
})

-- ESP Function
local function createESP(character)
    if character:FindFirstChild("Head") and not character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Adornee = character.Head
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = character

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = character.Name
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextScaled = true
        textLabel.Parent = billboard
    end
end

local ESPEnabled = false
local ESPConnection = nil

local Toggle = MainTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Toggle",
    Callback = function(Value)
        ESPEnabled = Value

        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    createESP(player.Character)
                end
            end

            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    task.wait(1)
                    if ESPEnabled then
                        createESP(character)
                    end
                end)
            end)

            ESPConnection = game:GetService("RunService").RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        createESP(player.Character)
                    end
                end
            end)
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Highlight") then
                    player.Character.Highlight:Destroy()
                end
                if player.Character and player.Character:FindFirstChild("NameTag") then
                    player.Character.NameTag:Destroy()
                end
            end

            if ESPConnection then
                ESPConnection:Disconnect()
                ESPConnection = nil
            end
        end
    end
})

-- Player Mods Tab (Speed & Jump Sliders)
local ModsTab = Window:CreateTab("Player Mods", 120763171259943)

local SpeedSlider = ModsTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

local JumpSlider = ModsTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

-- Kick Player Section
local KickSection = ModsTab:CreateSection("Kick Player")

local UsernameToKick = ""

local KickTextbox = ModsTab:CreateInput({
    Name = "Username to Kick",
    PlaceholderText = "Enter username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        UsernameToKick = Text
    end,
})

local KickButton = ModsTab:CreateButton({
    Name = "Kick Player",
    Callback = function()
        local targetPlayer = Players:FindFirstChild(UsernameToKick)
        if targetPlayer then
            targetPlayer:Kick("You have been kicked by the host.")
            Rayfield:Notify({
                Title = "Player Kicked",
                Content = UsernameToKick .. " has been kicked.",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Player Not Found",
                Content = "No player with the username '" .. UsernameToKick .. "' was found.",
                Duration = 3
            })
        end
    end,
})

-- 🔒 Auto Lock-On System
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local lockOnTarget = nil

local MAX_DISTANCE = 100
local LOCK_RADIUS = 50

local function getEnemies()
    local enemies = {}
    for _, model in pairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= LocalPlayer.Character then
            table.insert(enemies, model)
        end
    end
    return enemies
end

local function hasLineOfSight(target)
    local origin = camera.CFrame.Position
    local targetPart = target:FindFirstChild("HumanoidRootPart")
    if not targetPart then return false end

    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local result = workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(target)
end

local function getNearestEnemy()
    local closest = nil
    local closestDistance = MAX_DISTANCE

    for _, enemy in ipairs(getEnemies()) do
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        if hrp then
            local distance = (hrp.Position - camera.CFrame.Position).Magnitude
            if distance <= closestDistance then
                local direction = (hrp.Position - camera.CFrame.Position).Unit
                local dot = camera.CFrame.LookVector:Dot(direction)
                if dot > math.cos(math.rad(LOCK_RADIUS)) then
                    if hasLineOfSight(enemy) then
                        closestDistance = distance
                        closest = enemy
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    local newTarget = getNearestEnemy()
    if newTarget and newTarget:FindFirstChild("HumanoidRootPart") then
        lockOnTarget = newTarget
        local targetPos = lockOnTarget.HumanoidRootPart.Position
        local camPos = camera.CFrame.Position
        camera.CFrame = CFrame.new(camPos, targetPos)
    else
        lockOnTarget = nil
    end
end)



