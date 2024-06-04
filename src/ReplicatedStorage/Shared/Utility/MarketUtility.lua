local MarketUtility = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local MarketData = require(ReplicatedStorage.Shared.Configuration.MarketData)
local TableUtil = require(ReplicatedStorage.Shared.Utility.TableUtility)

local Cache = {}
local ClientPreloadPrices = {"Fast Hatching"}
local GetProfile

if RunService:IsServer() then
    local DataUtility

    task.defer(function()
        DataUtility = require(ServerStorage.Modules.DataUtility)
    end)
    
    function GetProfile(Player)
        return DataUtility:GetProfilePromise(Player):expect()
    end
else
    local ClientGlobals = require(ReplicatedStorage.Controllers.ClientGlobals)

    function GetProfile()
        return ClientGlobals.Replica
    end
end

local GetProductInformation = Promise.promisify(function(AssetID, InformationType)
    local UniqueID = `{AssetID}-{InformationType}`

    if AssetID ~= nil and InformationType ~= nil then
        if not Cache[UniqueID] then
            Cache[UniqueID] = MarketplaceService:GetProductInfo(AssetID, InformationType)
        end
    
        return table.clone(Cache[UniqueID])
    end
end)

function MarketUtility:ProductOfType(ProductType)
    local Result = {}

    for i,v in MarketData.Products do
        if v.ProductType == ProductType then
            Result[i] = v
        end
    end

    return Result
end

function MarketUtility:Price(AssetName)
    return MarketUtility:GetProductInformation(AssetName):andThen(function(ProductInformation)
        return ProductInformation.PriceInRobux or -1
    end)
end

function MarketUtility:HasGamepass(Player, PassName)
    local Profile = GetProfile(Player)

    if table.find(Profile.Data.Gamepasses, PassName) or Profile.Data.TempGamepasses[PassName] then
        return true
    end

    return false
end

function MarketUtility:GetAssetIDFromName(AssetName)
    if MarketData.Products[AssetName] then
        return MarketData.Products[AssetName].ID, Enum.InfoType.Product

    elseif MarketData.Gamepasses[AssetName] then
        return MarketData.Gamepasses[AssetName].ID, Enum.InfoType.GamePass
    end
end

function MarketUtility:GetAssetNameFromID(AssetID)
    for i, Collection in {MarketData.Products, MarketData.Gamepasses} do
		for AssetName, AssetData in Collection do
			if AssetData.ID == AssetID or AssetData.GiftID == AssetID then
				local InformationType = if i == 1 then Enum.InfoType.Product else Enum.InfoType.GamePass

				return AssetName, InformationType, AssetData.GiftID == AssetID
			end
		end
	end
end

function MarketUtility:GetProductInformation(Asset, InformationType)
    InformationType = InformationType or Enum.InfoType.Product
    
    local AssetID

    if type(Asset) == "string" then
        AssetID, InformationType = self:GetAssetIDFromName(Asset)
        assert(AssetID, "Invalid asset name: " .. Asset)
    else
        AssetID = Asset
    end

    return GetProductInformation(AssetID, InformationType):catch(function(Error)
        warn("Failed to get ProductInformation for " .. tostring(Asset) .. "! Error: " .. Error)
    end)
end

if RunService:IsClient() then
    for _,v in ClientPreloadPrices do
        MarketUtility:Price(v)
    end
end

return MarketUtility