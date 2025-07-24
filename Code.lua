local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ESP, SpeedHack, JumpHack, LockOn",
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
local RunService = game:GetService("RunService")

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

local ToggleESP = MainTab:CreateToggle({
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

            ESPConnection = RunService.RenderStepped:Connect(function()
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

-- Player Mods Tab (Speed & Jump Sliders + Lock-On)
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

-- Auto Lock-On Logic --

local lockOnEnabled = false
local lockOnConnection

local function getNearestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local hrp = character.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local enemyHRP = player.Character.HumanoidRootPart
            local distance = (enemyHRP.Position - hrp.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestEnemy = player.Character
            end
        end
    end

    return closestEnemy
end

local function rotateCharacterToTarget(targetPos)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local lookVector = (targetPos - hrp.Position)
    lookVector = Vector3.new(lookVector.X, 0, lookVector.Z)
    if lookVector.Magnitude == 0 then return end
    lookVector = lookVector.Unit

    local targetCFrame = CFrame.new(hrp.Position, hrp.Position + lookVector)
    hrp.CFrame = targetCFrame
end

local function onRenderStep()
    local target = getNearestEnemy()
    if target and target:FindFirstChild("HumanoidRootPart") then
        local targetPos = target.HumanoidRootPart.Position
        rotateCharacterToTarget(targetPos)
    end
end

local LockOnToggle = ModsTab:CreateToggle({
    Name = "Auto Lock-On",
    CurrentValue = false,
    Flag = "LockOnToggle",
    Callback = function(value)
        lockOnEnabled = value
        if lockOnEnabled then
            lockOnConnection = RunService.RenderStepped:Connect(onRenderStep)
        else
            if lockOnConnection then
                lockOnConnection:Disconnect()
                lockOnConnection = nil
            end
        end
    end
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





