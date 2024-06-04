local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerUtils = {}
local Assets = ReplicatedStorage.Assets

local function UpdateOrCreateTag(Character)
    local Head = Character:FindFirstChild("Head")

    if not Head then
        return
    end

    local ExistingTag = Head:FindFirstChild("PlayerTag")

    if ExistingTag then
        ExistingTag.Adornee = Head
    else
        local Tag = Assets.UI.Nametags.PlayerTag:Clone()

        Tag.Name = "PlayerTag"
        Tag.Adornee = Head
        Tag.PlayerName.Text = Players:GetPlayerFromCharacter(Character).Name
        Tag.DisplayName.Text = `@{Players:GetPlayerFromCharacter(Character).DisplayName}`
        Tag.AlwaysOnTop = false
        Tag.Parent = Head
    end
end

local function HandleCharacterAdded(Character)
    UpdateOrCreateTag(Character)

    Character.ChildAdded:Connect(function(Child)
        if Child:IsA("BasePart") and Child.Name == "Head" then
            UpdateOrCreateTag(Character)
        end
    end)
end

local function HandlePlayerAdded(Player)
    Player.CharacterAdded:Connect(HandleCharacterAdded)

    if Player.Character then
        HandleCharacterAdded(Player.Character)
    end
end

function PlayerUtils.InitializePlayerConnections()
    for _, Player in ipairs(Players:GetPlayers()) do
        HandlePlayerAdded(Player)
    end

    Players.PlayerAdded:Connect(HandlePlayerAdded)
end

return PlayerUtils
