local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)

local Assets = ReplicatedStorage.Assets
local Player = Players.LocalPlayer

local Animations = {
    Idle = {},
    Swing = {}
}

local AnimimationNamesById = {}

for _, v in ipairs(Assets.Animations.Sword:GetChildren()) do
    AnimimationNamesById[v.AnimationId] = v.Name
end

local function LoadAnimations(Humanoid)
    local AnimationFolder = Assets.Animations.Sword

    for _, Animation in ipairs(AnimationFolder:GetChildren()) do
        local Track = Humanoid:LoadAnimation(Animation)
        local Key = Animation.Name:match("Idle") and "Idle" or "Swing"
        Animations[Key][Animation.Name] = Track
    end
end

local function GetAnimationGroup()
    return ClientGlobals.Replica.Data.EquippedSword and "OneHand" or nil
end

local function UpdateIdleAnimation()
    local Group = GetAnimationGroup()

    if not Group then return end

    for Name, Track in pairs(Animations.Idle) do
        if Name:match(Group .. "Idle") then
            Track:Play()
        else
            Track:Stop()
        end
    end
end

local function InitialiseAnimationTracking(Character)
    local Humanoid = Character:WaitForChild("Humanoid", 7)

    if Humanoid then
        Humanoid.AnimationPlayed:Connect(function(Track)
            if not Humanoid.RootPart then return end

            local Name = AnimimationNamesById[Track.Animation.AnimationId]

            if Name and Name:match("Swing") then
                local OutlineContainer = Character:FindFirstChild("OutlineContainer")
                local Weapons = { OutlineContainer:FindFirstChild("EquippedSword1") }

                if (not Humanoid.RootPart:FindFirstChild("_SwingSound")) or (Character == Player.Character) then
                    local SwingSound = SoundService.Game:FindFirstChild(`SwordSwing1`):Clone()
                    SwingSound.Name = "_SwingSound"
                    SwingSound.PlaybackSpeed = math.random(95, 115) / 100
                    SwingSound.Parent = Humanoid.RootPart
                    SwingSound:Play()
                    Debris:AddItem(SwingSound, SwingSound.TimeLength)
                end

                for _, v in ipairs(Weapons) do
                    local Trail = v:FindFirstChild("SwingTrail")

                    if not Trail then continue end

                    Track:GetMarkerReachedSignal("Start"):Once(function()
                        Trail.Enabled = true
                    end)

                    Track:GetMarkerReachedSignal("End"):Once(function()
                        Trail.Enabled = false
                    end)
                end
            end
        end)
    end
end

return {
    LoadAnimations = LoadAnimations,
    UpdateIdleAnimation = UpdateIdleAnimation,
    InitialiseAnimationTracking = InitialiseAnimationTracking,
    GetAnimationGroup = GetAnimationGroup,
    Animations = Animations
}
