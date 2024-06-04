local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RegisterHit = {}

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataUtility = require(ServerStorage.Modules.DataUtility)
local RNGUtility = require(ReplicatedStorage.Shared.Utility.RNGUtility)

local HIT_DISTANCE_THRESHOLD = 25
local HitWhitelist = {}
local EnemyService

Knit.OnStart():andThen(function()
    EnemyService = Knit.GetService("EnemyService")
end)

function RegisterHit:Initialize(SwordService)
    SwordService.Client.RegisterHit = self.RegisterHit
end

function RegisterHit.RegisterHit(Player, EnemyModel)
    if HitWhitelist[Player] then return false end

    if not Player.Character or not EnemyService:Query(EnemyModel) then return false end

    local PlayerPosition = Player.Character.PrimaryPart.Position
    local EnemyPosition = EnemyService:CurrentPosition(EnemyModel)

    if (PlayerPosition - EnemyPosition).Magnitude > HIT_DISTANCE_THRESHOLD then return false end

    local Profile = DataUtility:GetProfile(Player)

    if not Profile then return false end

    local HitDamage = 1 --// Gotta change this
    local Hit = Knit.GetService("EnemyService"):DamageEnemy(Player, EnemyModel, HitDamage)
    if Hit then
        Knit.GetService("EnemyService").Client.Animate:FireExcept(Player, EnemyModel, "Hit")
    end

    HitWhitelist[Player] = true

    task.delay(0.85 - 0.1, function()
        HitWhitelist[Player] = nil
    end)

    -- if not Profile.Data.SessionData.NextHitCrit then
    --     Profile.Data.SessionData.NextHitCrit = RNGUtility:FromChanceFloat(ProgressionUtility:ReadValue(Player, "CritChance"))
    -- end

    -- DataUtility:Replicate(Player, {"SessionData", "NextHitCrit"})
    return true
end

return RegisterHit
