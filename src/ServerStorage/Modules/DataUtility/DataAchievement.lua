local DataAchievement = {}

local DataProfile = require(script.Parent.DataProfile)
local DataReplicate = require(script.Parent.DataReplicate)

function DataAchievement:GiveAchievement(Player, WorldName, Achievement)
	local Profile = DataProfile:GetProfile(Player)
	local ProfileAchievements = Profile.Data.WorldQuests

	if not ProfileAchievements[Achievement] then
		ProfileAchievements[Achievement] = {}
	end

	ProfileAchievements[Achievement] = {Progress = 0}
	Profile.Data.WorldQuests = ProfileAchievements
	DataReplicate:Replicate(Player, "WorldQuests")
end

function DataAchievement:UpdateAchievement(Player, WorldName, Achievement, NewValue)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.WorldQuests[Achievement].Progress = NewValue
	DataReplicate:Replicate(Player, "WorldQuests")
end

function DataAchievement:CompleteAchievement(Player, WorldName, Achievement)
	local Profile = DataProfile:GetProfile(Player)

	Profile.Data.WorldQuests[Achievement].Finished = true
	DataReplicate:Replicate(Player, "WorldQuests")
end

return DataAchievement
