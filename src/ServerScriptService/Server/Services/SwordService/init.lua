local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataUtility = require(ServerStorage.Modules.DataUtility)
local HandleSwordEquipping = require(script.HandleSwordEquipping)
local ClientRequests = require(script.ClientRequests)
-- local RegisterHit = require(script.RegisterHit)

local SwordService = Knit.CreateService({
    Name = "SwordService",
    Client = {}
})

SwordService.Client = ClientRequests

function SwordService:KnitStart()
    local function OnPlayerAdded(Player)
        Player.CharacterAdded:Connect(function()
            HandleSwordEquipping(Player)
        end)

        if Player.Character then
            HandleSwordEquipping(Player)
        end

        DataUtility:GetProfilePromise(Player):andThen(function()
            HandleSwordEquipping(Player)
        end)
    end

    for _, Player in ipairs(Players:GetPlayers()) do
        OnPlayerAdded(Player)
    end

    Players.PlayerAdded:Connect(OnPlayerAdded)
end

function SwordService:KnitInit()
    -- RegisterHit:Initialize(self)
end

return SwordService
