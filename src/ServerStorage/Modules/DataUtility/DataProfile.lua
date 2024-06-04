local DataProfile = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService

Knit.OnStart():andThen(function()
    DataService = Knit.GetService("DataService")
end)

function DataProfile:GetProfile(Player)
	return DataService.GetProfile(Player)
end

function DataProfile:GetProfilePromise(Player)
	return DataService.GetProfilePromise(Player)
end

function DataProfile:GetReplica(Player)
	return DataService.GetReplica(Player)
end

return DataProfile
