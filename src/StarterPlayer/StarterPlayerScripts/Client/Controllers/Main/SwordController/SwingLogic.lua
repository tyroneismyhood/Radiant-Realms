local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)
local LoadAnimations = require(script.Parent.LoadAnimations)

local Player = Players.LocalPlayer
local Replica = ClientGlobals.Replica

local CanSwing = true
local IsSwinging = false
local LastSwingTime = 0

local function SwingSword()
    if not CanSwing or not Replica.Data.EquippedSword then return end

    CanSwing = false
    LastSwingTime = time()

    local SwingDuration = 0.85
    local Group = LoadAnimations.GetAnimationGroup()
    local Track = LoadAnimations.Animations.Swing[Group .. "Swing"]

    if Track and not Track.IsPlaying then
        Track:Play(0.1, 1, Track.Length / SwingDuration)
    end

    IsSwinging = true

    task.delay(SwingDuration / 2, function()
        IsSwinging = false
    end)

    task.delay(SwingDuration, function()
        CanSwing = true
    end)
end

local function UpdateSwing(deltaTime)
    if IsSwinging then
        local character = Player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        local currentTime = time()
        local swingDuration = 0.85

        -- Reset the swinging flag after the swing duration
        if currentTime >= LastSwingTime + swingDuration then
            IsSwinging = false
        end
    end
end

return {
    SwingSword = SwingSword,
    UpdateSwing = UpdateSwing
}