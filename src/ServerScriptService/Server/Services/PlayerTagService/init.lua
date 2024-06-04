local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlayerUtils = require(script.PlayerUtils)

local PlayerTagService = Knit.CreateService({
    Name = "PlayerTagService"
})

function PlayerTagService:KnitStart()
    PlayerUtils.InitializePlayerConnections()
end

return PlayerTagService
