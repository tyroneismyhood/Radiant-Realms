local BadgeModule = {}

local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local DataUtility = require(ServerStorage.Modules.DataUtility)

local AwardedBadgeProcess = {}
local SimulateAwardInStudio = true

function BadgeModule:Award(Player, BadgeID)
    if not BadgeID or AwardedBadgeProcess[Player.UserId .. "," .. BadgeID] then
        return
    end

    local Resolved, Profile = DataUtility:GetProfilePromise(Player):await()

    if not Resolved or not Profile or table.find(Profile.Data.AwardedBadges, BadgeID) then
        return
    end

    AwardedBadgeProcess[Player.UserId .. "," .. BadgeID] = true

    local Success = false

    if SimulateAwardInStudio and RunService:IsStudio() then
        Success = true
    else
        Success = pcall(function() 
            BadgeService:AwardBadge(Player.UserId, BadgeID) 
        end)
    end

    if Success then
        table.insert(Profile.Data.AwardedBadges, BadgeID)
        DataUtility:Replicate(Player, "AwardedBadges")
    else
        warn("Failed to award badge", BadgeID)
    end

    AwardedBadgeProcess[Player.UserId .. "," .. BadgeID] = nil
end

return BadgeModule
