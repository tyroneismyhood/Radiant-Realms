local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataServiceConfig = require(script.DataServiceConfig)
local InitializeDataServiceFunctions = require(script.DataServiceFunctions)

local DataService = Knit.CreateService({
    Name = "DataService",
    Client = {},
    OnProfileCreated = DataServiceConfig.Signal.new(),
})

InitializeDataServiceFunctions(DataService)

function DataService:InitializePlayerConnections()
    Players.PlayerAdded:Connect(function(Player)
        DataService.LoadProfileAndReplica(Player)
    end)
end

function DataService:KnitStart()
    self:InitializePlayerConnections()
end

function DataService:KnitInit()
    
end

return DataService