local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LoadAnimations = require(script.Parent.LoadAnimations)

local Player = Players.LocalPlayer

local function InitializeCharacter(Player)
    local function OnCharacterAdded(Character)
        task.spawn(LoadAnimations.InitialiseAnimationTracking, Character)
        LoadAnimations.LoadAnimations(Character:WaitForChild("Humanoid"))
        LoadAnimations.UpdateIdleAnimation()
    end

    if Player.Character then
        task.spawn(OnCharacterAdded, Player.Character)
    end

    Player.CharacterAdded:Connect(OnCharacterAdded)
end

return InitializeCharacter
