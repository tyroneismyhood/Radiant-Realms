local DataItemManagement = {}

local DataProfile = require(script.Parent.DataProfile)
local DataReplicate = require(script.Parent.DataReplicate)
local DataUtilityConfig = require(script.Parent.DataUtilityConfig)

local function FindAvailableUUID(Table, Key)
	local Counter = 0

	while true do
		local UUID = Key .. Counter

		if not Table[UUID] then
			return UUID
		else
			Counter += 1
		end
	end
end

function DataItemManagement:SetPetIsEquipped(Player, PetID, Equipped)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.Pets[PetID].Equipped = if Equipped then true else nil
	DataReplicate:Replicate(Player, "Pets")
end

function DataItemManagement:GivePet(Player, PetToGive)
	local PetData

	if type(PetToGive) == "string" then
		PetData = table.clone(DataUtilityConfig.PetStruct)
		PetData.Name = PetToGive

	elseif type(PetToGive) == "table" then
		PetData = PetToGive

		for i, Default in DataUtilityConfig.PetStruct do
			if Default == "required" and not PetToGive[i] then
				error(`Invalid Pet Data expected {i} field`)
			else
				PetToGive[i] = PetToGive[i] or Default
			end
		end
	else
		error("Invalid petToGive (expected string or table)")
	end

	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.Pets[FindAvailableUUID(Profile.Data.Pets, PetData.Name)] = PetData
	DataReplicate:Replicate(Player, "Pets")
	return PetData
end

function DataItemManagement:GiveSword(Player, SwordToGive)
	local SwordData

	if type(SwordToGive) == "string" then
		SwordData = table.clone(DataUtilityConfig.SwordStruct)
		SwordData.Name = SwordToGive

	elseif type(SwordToGive) == "table" then
		SwordData = DataReplicate:DeepCopy(SwordToGive)

		for i, Default in DataUtilityConfig.SwordStruct do
			if Default == "required" and not SwordToGive[i] then
				error(`Invalid Sword Data expected {i} field`)
			else
				SwordToGive[i] = SwordToGive[i] or Default
			end
		end
	else
		error("Invalid swordToGive (expected string or table)")
	end

	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.Swords[FindAvailableUUID(Profile.Data.Swords, SwordData.Name)] = SwordData
	DataReplicate:Replicate(Player, "Swords")
	return SwordData
end

return DataItemManagement
