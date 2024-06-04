local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataServiceConfig = {
    DataKey = "Main_Data_0.3",
    TestingDataKey = "Testing_Data_0.3",
    PlayerDataToken = require(ServerStorage.Modules.ReplicaService).NewClassToken("PlayerDataV1"),
    Signal = require(ReplicatedStorage.Packages.Signal),
    Promise = require(ReplicatedStorage.Packages.Promise),
}

return DataServiceConfig