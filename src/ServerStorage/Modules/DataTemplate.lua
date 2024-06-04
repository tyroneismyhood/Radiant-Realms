local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- local Worlds = require(ReplicatedStorage.Shared.Configuration.WorldsConfig)

local StartWorlds = {"Forest"}

-- if RunService:IsStudio() and false then
-- 	StartWorlds = {}

-- 	for i, v in Worlds do
-- 		table.insert(StartWorlds, i)
-- 	end
-- end

local ProfileTemplate = {
    	-- Core
	["Coins"] = 0,
	["PeakCoins"] = 0,
	["Gems"] = 0,
	["PeakGems"] = 0,
	["Rebirth"] = 1,
	["Trophys"] = 0,
	["Power"] = 0,
	["PeakPower"] = 0,
	["CurrentWorld"] = "Forest",
	["Worlds"] = StartWorlds,
	["Pets"] = {},
	["Eggs"] = {},
	["EquippedPets"] = {},
	["EquippedMount"] = "Cerulean Surf",
	["Mounts"] = {
		["Cerulean Surf"] = true
	},
	["Country"] = "",
	["WorldQuests"] = {},
	
	["Items"] = {

	},

	["LastLoginDay"] = 0,
	["LoginStreak"] = 0,
	["LastWheelClaimPlayTime"] = 0,
	["LastChestClaims"] = {},
	["EquippedSword"] = "FirstWep_1",

	["Swords"] = {
		["FirstWep_1"] = {
			Name = "SharkAttack",
			PermaLock = true,
			Grade = "Normal", 
		},
	},
    	
	["UnlockedTrials"] = {
		["Normal"] = true,
	},

	["BiggestVersionPlayed"] = { 0, 0, 0 },
	["Gamepasses"] = {},
	["TempGamepasses"] = {},
	["Receipts"] = {},
	["TutorialStep"] = 1,
	["TimeSpentOnTutorialStep"] = 0,
	["StarterPackTimer"] = 10800,
	["PurchasedStarterPack"] = false,
	["ShowStarterPack"] = true,
	
	["Index"] = {
		["Pets"] = {},
		["Weapons"] = {},
		["Mounts"] = {}
	},

	["SumPetsFound"] = 0,
	["SumWeaponsFound"] = 0,
	["SumMountsFound"] = 0,

	["Stats"] = {
		["RobuxSpent"] = 0,
		["Playtime"] = 0,
		["EggsOpened"] = 0,
		["TotalCoins"] = 0,
		["TotalGems"] = 0,
		["BlocksBroken"] = 0,
		["PetPower"] = 0,
	},

	["LastTrialRoomCounts"] = 0,
	["BestTrialCompletes"] = {},

	["BestTrialRooms"] = {
		["Normal"] = 0,
		["Medium"] = 0,
		["Hard"] = 0,
	},

	["ActiveTasks"] = {},
	["TaskStock"] = {},
	["ActiveQuests"] = {},
	["CompletedQuests"] = {},
	["Boosts"] = {},
	["Fruits"] = {},
	["Toys"] = {},
	["Achievements"] = {},
	["Upgrades"] = {},
	["ClaimedIndexUpgrades"] = {},
	["Settings"] = {},

	["AutoDelete"] = {
		["Swords"] = {},
		["Pets"] = {},
	},

	["EnemyCooldowns"] = {},
	["RedeemedCodes"] = {},
	["TwitterVerified"] = false,
	["DiscordVerified"] = false,
	["GiftHistory"] = {},
	["AwardedBadges"] = {},
	["PurchasedPacks"] = {},
	["GiftTimePersist"] = 0,
	["GiftClaimPersist"] = 0,
	["TimeSpentInTopWorld"] = 0,
	["SpecificEggOpens"] = {},
	["SpecificEnemyKills"] = {},
	["LeaveTime"] = -1,
	["GiftTimeOffset"] = 0,
	["ClaimedGifts"] = {},
	["CanTrade"] = true,
	["Tokens"] = 0,
	["Level"] = 1,
	["EXP"] = 0,
	["WorldQuestKills"] = 0,
	["BadgesClaimed"] = {},
	["Merchants"] = {},

	["Rank"] = {
		ID = 1,
		Level = 1,
		Claimed = {},
		ActiveRewards = {},
		ActiveQuests = {}
	},

	["SessionData"] = {
		JoinTime = 0,
		NextHitCrit = false,
		GiftsClaimed = 0,
		EnemyHealths = {},
		TimePlayed = 0,
		ClaimedFreeRewards = {},
		PowerBoost = 0,
		PurchasedGifts = false,
		WheelRewardset = 1,
		Health = 1000,

		["FreePet"] = {
			Invited = 0,
			Played = 0,
			Claimed = false
		},
	},
    
	["RunOnceFlagsOGGV23"] = {},
}

return ProfileTemplate