local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService

Knit.OnStart():andThen(function()
    DataService = Knit.GetService("DataService")
end)

local function IndexTableByPath(Head, Path)
	local Child = Head

	for i = 1, #Path do
		Child = Child[Path[i]]
	end

	return Child
end

local DataReplicate = {}

function DataReplicate:Replicate(Player, ...)
	local Profile = DataService.GetProfile(Player)
	local Replica = DataService.GetReplica(Player)

	if Profile and Replica then
		for _, Path in { ... } do
			local Value

			if type(Path) == "table" then
				Value = IndexTableByPath(Profile.Data, Path)
			else
				Value = Profile.Data[Path]
			end

			Replica:SetValue(Path, Value)
		end
	end
end

function DataReplicate:DeepCopy(Table)
	assert(type(Table) == "table", `cannot deep copy a non table`)

	local NewTable = {}

	for i, v in Table do
		if type(v) == "table" then
			v = DataReplicate:DeepCopy(v)
		end

		NewTable[i] = v
	end
    
	return NewTable
end

return DataReplicate
