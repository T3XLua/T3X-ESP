local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ESP, SpeedHack, JumpHack",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by dizzy",
    ShowText = "Rayfield",
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

    ToggleUIKeybind = "K",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "dizzy Hub"
    },

    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },

    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = { "Hello" }
    }
})

local MainTab = Window:CreateTab("ESP", 120763171259943)
local MainSection = MainTab:CreateSection("Enabled")

Rayfield:Notify({
    Title = "Executed",
    Content = "Have Fun!",
    Duration = 3,
    Image = nil
})

local Toggle = MainTab:CreateToggle({
    Name = "Toggle Example",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        -- Function to create ESP for a character
        local function createESP(character)
            if character:FindFirstChild("Head") then
                -- Highlight
                local highlight = Instance.new("Highlight")
                highlight.Adornee = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = character

                -- Billboard GUI for name
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

        -- Apply ESP to all players except LocalPlayer
        local function applyESP()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("Highlight") then
                        createESP(player.Character)
                    end
                end
            end
        end

        -- Listen for players joining or respawning
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                task.wait(1)
                createESP(character)
            end)
        end)

        -- Initial ESP
        game:GetService("RunService").RenderStepped:Connect(applyESP)
    end,
})


-- Apply ESP to all players except LocalPlayer
local function applyESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not player.Character:FindFirstChild("Highlight") then
                createESP(player.Character)
            end
        end
    end
end

-- Listen for players joining or respawning
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        createESP(character)
    end)
end)

-- Initial ESP
game:GetService("RunService").RenderStepped:Connect(applyESP)


