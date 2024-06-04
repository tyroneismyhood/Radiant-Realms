local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataUtility = require(ServerStorage.Modules.DataUtility)
local AssetUtility = require(ReplicatedStorage.Shared.Utility.AssetUtility)
local MountUtility = require(script.MountUtility)
local Mounts = require(ReplicatedStorage.Shared.Configuration.MountConfig)

local MountService = Knit.CreateService({
    Name = "MountService",
    Client = {},
})

local Cooldowns = {}

function MountService.Client:ChangeMount(Player, MountName)
    local Profile = DataUtility:GetProfile(Player)

    if Profile.Data.Mounts[MountName] and Profile.Data.EquippedMount ~= MountName then
        Profile.Data.EquippedMount = MountName
        DataUtility:Replicate(Player, "EquippedMount")
    end
end

function MountService.Client:Mount(Player)
    if Cooldowns[Player] then
        return
    end

    local Profile = DataUtility:GetProfile(Player)

    if not Profile.Data.Mounts[Profile.Data.EquippedMount] then
        return false
    end

    Cooldowns[Player] = true

    task.delay(1.5, function() 
        Cooldowns[Player] = nil 
    end)

    local Character = Player.Character

    if Character then
        local CurrentMount = Character:FindFirstChild("Mount")

        if CurrentMount then 
            CurrentMount:Destroy() 
        end

        local Model = AssetUtility:GenericAsset("Mounts", Profile.Data.EquippedMount):Clone()

        Model.Name = "Mount"
        Model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
        Model.Parent = Character
        MountUtility.SetupMountModel(Model, Mounts[Profile.Data.EquippedMount], Character)

        return true
    end
end

function MountService.Client:Unmount(Player)
    self.Server:UnmountPlayer(Player)
end

function MountService:UnmountPlayer(Player)
    local Character = Player.Character

    if Character then
        local Model = Character:FindFirstChild("Mount")

        if Model then 
            Model:Destroy() 
        end
    end
end

function MountService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(Character)
            Character:WaitForChild("Humanoid").Died:Connect(function()
                self:UnmountPlayer(Player)
            end)
        end)
    end)
end

return MountService