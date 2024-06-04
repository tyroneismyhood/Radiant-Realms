local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataServiceConfig = require(script.Parent.DataServiceConfig)
-- local ProgressionUtility = require(ReplicatedStorage.Shared.Utility.Progression)
local ProfileTemplate = require(ServerStorage.Modules.DataTemplate)
local InitializeCallbacks = require(script.Parent.DataServiceCallbacks)
local InitializeProfileStore = require(script.Parent.DataServiceStore)
local ReplicaService = require(ServerStorage.Modules.ReplicaService)

local RunOnceCallbacks, AfterLoadedCallbacks = InitializeCallbacks()
local GameProfileStore = InitializeProfileStore()

local Profiles = {}
local Replicas = {}

local function InitializeDataServiceFunctions(DataService)
    -- DataService.Client.GetPlayerTopWorld = function(_, Target)
    --     return ProgressionUtility:GetPlayerTopWorld(Target)
    -- end

    DataService.GetReplica = function(Player)
        return Replicas[Player]
    end

    DataService.GetProfile = function(Player)
        return Profiles[Player]
    end

    DataService.GetProfilePromise = function(Player)
        if Profiles[Player] then
            return DataServiceConfig.Promise.resolve(Profiles[Player])
        end

        local CreatedConnection
        local LeaveConnection

        return DataServiceConfig.Promise.new(function(Resolve, Reject)
            CreatedConnection = DataService.OnProfileCreated:Connect(function(Plr, Profile)
                if Plr == Player then
                    Resolve(Profile)
                end
            end)

            LeaveConnection = Players.PlayerRemoving:Connect(function(Plr)
                if Plr == Player then
                    Reject("Player left the game")
                end
            end)
        end):finally(function()
            CreatedConnection:Disconnect()
            LeaveConnection:Disconnect()
        end)
    end

    DataService.LoadProfileAndReplica = function(Player)
        -- Leaderstats setup
        local Leaderstats = Instance.new("Folder")

        Leaderstats.Name = "leaderstats"
        Leaderstats.Parent = Player

        local Coins = Instance.new("StringValue")

        Coins.Name = "Coins"
        Coins.Value = "--"
        Coins.Parent = Leaderstats

        local Gems = Instance.new("StringValue")

        Gems.Name = "Gems"
        Gems.Value = "--"
        Gems.Parent = Leaderstats

        local TeleportData = Player:GetJoinData().TeleportData

        if TeleportData and TeleportData.reconnecting and game.PrivateServerId ~= "" then
            return
        end

        local UserID = Player.UserId
        local Key

        if game.PlaceId == 0 then
            Key = "Player_" .. UserID .. "@" .. DataServiceConfig.TestingDataKey
        else
            Key = "Player_" .. UserID .. "@" .. DataServiceConfig.DataKey
        end

        local Profile = GameProfileStore:LoadProfileAsync(Key, "ForceLoad")

        if Profile then
            Profile:AddUserId(Player.UserId)
            Profile:Reconcile()

            Profile:ListenToRelease(function()
                Profile.Data.LeaveTime = workspace:GetServerTimeNow()

                if Profile.Data.SessionData.JoinTime > 0 then
                    Profile.Data.GiftClaimPersist = Profile.Data.SessionData.GiftsClaimed
                    Profile.Data.GiftTimePersist += workspace:GetServerTimeNow() - Profile.Data.SessionData.JoinTime
                    Profile.Data.SessionData = table.clone(ProfileTemplate.SessionData)
                end

                Profiles[Player] = nil

                if not Player:GetAttribute("Hopping") then
                    Player:Kick("Data loaded elsewhere.")
                end
            end)

            if Player:IsDescendantOf(Players) then
                Profiles[Player] = Profile

                for _, Callback in ipairs(AfterLoadedCallbacks) do
                    Callback(Profile, Player)
                end

                -- RunOnceCallbacks execution
                for CallbackKey, Callback in pairs(RunOnceCallbacks) do
                    if not Profile.Data.RunOnceFlagsOGGV23[CallbackKey] then
                        Callback(Profile, Player)
                        Profile.Data.RunOnceFlagsOGGV23[CallbackKey] = true
                    end
                end

                -- Setup Replica
                local ReplicaData = {}

                for Index in pairs(ProfileTemplate) do
                    ReplicaData[Index] = Profile.Data[Index]
                end

                local Replica = ReplicaService.NewReplica({
                    ClassToken = DataServiceConfig.PlayerDataToken,
                    Data = ReplicaData,
                    Replication = Player,
                })

                Replicas[Player] = Replica
                DataService.OnProfileCreated:Fire(Player, Profile)
            else
                Profile:Release()
            end
        else
            Player:Kick("Failed to load player data.")
        end
    end

    Players.PlayerRemoving:Connect(function(Player)
        local Profile = Profiles[Player]

        if Profile then
            Profile:Release()
        end
    end)
end

return InitializeDataServiceFunctions