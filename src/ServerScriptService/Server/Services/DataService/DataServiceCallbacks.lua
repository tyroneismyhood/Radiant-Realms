local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BadgeService = require(ServerStorage.Modules.BadgeModule)
local DataUtility = require(ServerStorage.Modules.DataUtility)
local ProfileTemplate = require(ServerStorage.Modules.DataTemplate)

local function InitializeCallbacks()
    local RunOnceCallbacks = {
        ["first_spin_token"] = function(Profile)
            if not Profile.Data.Items["Spin Token"] then
                Profile.Data.Items["Spin Token"] = 1
            end
        end,

        ["StarterPack"] = function(Profile, Player)
            if #Profile.Data.Worlds > 2 then
                Profile.Data.ShowStarterPack = false
            else
                Profile.Data.ShowStarterPack = true
            end

            DataUtility:Replicate(Player, "ShowStarterPack")
        end,
    }

    local AfterLoadedCallbacks = {
        [1] = function(Profile)
            Profile.Data.SessionData = table.clone(ProfileTemplate.SessionData)
            Profile.Data.SessionData.JoinTime = workspace:GetServerTimeNow()
        end,

        [2] = function(Profile)
            local TimeSinceLeave = workspace:GetServerTimeNow() - Profile.Data.LeaveTime
            local Safezone = 60 * 5

            if Profile.Data.LeaveTime < 1000 then
                TimeSinceLeave = 1
            end

            if Profile.Data.GiftTimePersist > 3600 * 4 then
                Safezone = 60 * 10
            end

            if Profile.Data.GiftTimePersist > 3600 * 8 then
                Safezone = 60 * 20
            end

            if Profile.Data.GiftTimePersist > 3600 * 16 then
                Safezone = 60 * 30
            end

            if TimeSinceLeave <= Safezone then
                Profile.Data.SessionData.GiftsClaimed = Profile.Data.GiftClaimPersist
            else
                Profile.Data.GiftTimePersist = 0
                Profile.Data.GiftClaimPersist = 0
            end
        end,

        [3] = function(_, player)
            DataUtility:UpdateLeaderstats(player)
        end,

        -- [4] = function(Profile)
        --     local GameVersion = ServerInfo.Build

        --     if GameVersion[1] > Profile.Data.BiggestVersionPlayed[1] or GameVersion[2] > Profile.Data.BiggestVersionPlayed[2] then
        --         Profile.Data.BiggestVersionPlayed = table.clone(GameVersion)
        --     end
        -- end,

        [5] = function(Profile, Player)
            for _, v in Profile.Data.Worlds do
                if BadgeService.Badges[v] ~= nil then
                    BadgeService:Award(Player, BadgeService.Badges[v])
                end
            end
        end,
    }

    return RunOnceCallbacks, AfterLoadedCallbacks
end

return InitializeCallbacks