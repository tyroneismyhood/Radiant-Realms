local DataUtility = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local FormatNumber = require(ReplicatedStorage.Shared.Utility.FormatNumber)
local RNGUtility = require(ReplicatedStorage.Shared.Utility.RNGUtility)
-- local ComboTypes = require(ReplicatedStorage.Shared.Configuration:WaitForChild("ComboTypes"))

local DataProfile = require(script.DataProfile)
local DataReplicate = require(script.DataReplicate)
local DataItemManagement = require(script.DataItemManagement)
local DataAchievement = require(script.DataAchievement)
local DataUtilityConfig = require(script.DataUtilityConfig)

-- local RewardService
-- local ShopService

Knit.OnStart():andThen(function()
	-- RewardService = Knit.GetService("RewardService")
	-- ShopService = Knit.GetService("ShopService")
end)

function DataUtility:SetPetIsEquipped(Player, PetID, Equipped)
    DataItemManagement:SetPetIsEquipped(Player, PetID, Equipped)
end

function DataUtility:Replicate(Player, ...)
    DataReplicate:Replicate(Player, ...)
end

function DataUtility:GetProfile(Player)
    return DataProfile:GetProfile(Player)
end

function DataUtility:GetProfilePromise(Player)
    return DataProfile:GetProfilePromise(Player)
end

function DataUtility:GetReplica(Player)
    return DataProfile:GetReplica(Player)
end

function DataUtility:AddReceipt(Player, ReceiptInformation)
	local Profile = DataProfile:GetProfile(Player)
	local Copy = {}

	for i, v in ReceiptInformation do
		Copy[i] = tostring(v)
	end

	table.insert(Profile.Data.Receipts, Copy)
end

function DataUtility:UpdateLeaderstats(Player)
	local Profile = DataProfile:GetProfile(Player)

	Player.leaderstats.Gems.Value = FormatNumber:Short(Profile.Data.Gems)
	Player.leaderstats.Coins.Value = FormatNumber:Short(Profile.Data.Coins)
end

function DataUtility:AddGamepass(Player, GamepassName)
	local Profile = DataProfile:GetProfile(Player)

	if not table.find(Profile.Data.Gamepasses, GamepassName) then
		table.insert(Profile.Data.Gamepasses, GamepassName)
		DataReplicate:Replicate(Player, "Gamepasses")
		-- ShopService.PassAdded:Fire(Player, GamepassName)

		return true
	end
end

function DataUtility:RewardCombo(Player)
	-- local Profile = DataProfile:GetProfile(Player)

	-- if Profile.Data.SessionData.NextHitCrit == true then
	-- 	local function GetRandomReward()
	-- 		local Chances = {}

	-- 		for ComboName, ComboInfo in ComboTypes do
	-- 			Chances[ComboName] = ComboInfo.Chance
	-- 		end
		
	-- 		return RNGUtility.SelectRandom(Chances)
	-- 	end

	-- 	-- Rewarding process

	-- 	local Reward = GetRandomReward()

	-- 	if Reward == "Bonus Gems" or Reward == "2x Coins" or Reward == "3x Coins" then
	-- 		local Information = ComboTypes[Reward]

	-- 		if Information ~= nil then
	-- 			DataUtility:Add(Player, Information.CurrencyName, Profile.Data[Information.CurrencyName] * Information.Multiply)
	-- 		end

	-- 	elseif Reward == "Potion Drop" then
	-- 		local Information = ComboTypes[Reward]

	-- 		if Information ~= nil then
	-- 			for BoostName, v in DataUtilityConfig.PotionDrops do
	-- 				RewardService:Award(Player, {
	-- 					Type = "Item",
	-- 					Name = BoostName,
	-- 					Amount = 1
	-- 				})
	-- 			end
	-- 		end

	-- 	elseif Reward == "Exclusive Egg" then
	-- 		warn("Work on later! Exclusive Egg!")

	-- 	elseif Reward == "Huge Pet" then
	-- 		warn("Work on later! Huge Pet!")
	-- 	end

	-- 	return Reward
	-- end
end

function DataUtility:UnlockTrialMode(Player, TrialMode)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.UnlockedTrials[TrialMode] = true
	DataReplicate:Replicate(Player, {"UnlockedTrials", TrialMode})
end

function DataUtility:AddTempPass(Player, GamepassName, Duration)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.TempGamepasses[GamepassName] = (Profile.Data.TempGamepasses[GamepassName] or 0) + Duration
	DataReplicate:Replicate(Player, "TempGamepasses")
end

function DataUtility:GiveMount(Player, MountName)
	local Profile = DataProfile:GetProfile(Player)

	if not Profile.Data.Mounts[MountName] then
		Profile.Data.Mounts[MountName] = true
		DataReplicate:Replicate(Player, "Mounts")
	end
end

function DataUtility:RewardTenPercent(Player)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.Power *= 1.10
	DataReplicate:Replicate(Player, "Power")
end

function DataUtility:GiveItem(Player, ItemName, Amount)
	local Profile = DataProfile:GetProfile(Player)

	if not Amount then
		Amount = 1
	end

	Profile.Data.Items[ItemName] = (Profile.Data.Items[ItemName] or 0) + Amount

	if Profile.Data.Items[ItemName] <= 0 then
		Profile.Data.Items[ItemName] = nil
	end

	DataReplicate:Replicate(Player, "Items")
end

function DataUtility:GiveAchievement(Player, WorldName, Achievement)
	DataAchievement:GiveAchievement(Player, WorldName, Achievement)
end

function DataUtility:UpdateAchievement(Player, WorldName, Achievement, NewValue)
	DataAchievement:UpdateAchievement(Player, WorldName, Achievement, NewValue)
end

function DataUtility:CompleteAchievement(Player, WorldName, Achievement)
	DataAchievement:CompleteAchievement(Player, WorldName, Achievement)
end

function DataUtility:GivePet(Player, PetToGive)
	return DataItemManagement:GivePet(Player, PetToGive)
end

function DataUtility:GiveSword(Player, SwordToGive)
	return DataItemManagement:GiveSword(Player, SwordToGive)
end

function DataUtility:AddGiftHistory(Player, Log)
	local Profile = DataProfile:GetProfile(Player)

	table.insert(Profile.Data.GiftHistory, Log)
	DataReplicate:Replicate(Player, "GiftHistory")
end

function DataUtility:Set(Player, Key, Amount)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data[Key] = Amount
	DataReplicate:Replicate(Player, Key)
end

function DataUtility:Add(Player, Key, Amount)
	local PKey = `Peak{Key}`
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data[Key] += Amount
	DataReplicate:Replicate(Player, Key)

	if Profile.Data[PKey] and Profile.Data[PKey] < Profile.Data[Key] then
		Profile.Data[PKey] = Profile.Data[Key]
		DataReplicate:Replicate(Player, PKey)
	end

	if Key == "Gems" or Key == "Coins" then
		DataUtility:UpdateLeaderstats(Player)
	end
end

function DataUtility:SetSetting(Player, SettingName, Value)
	local Profile = DataProfile:GetProfile(Player)
	local Replica = DataProfile:GetReplica(Player)

	Profile.Data.Settings[SettingName] = Value
	Replica:SetValue({ "Settings", SettingName }, Value)
end

return DataUtility
