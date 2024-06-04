local SortUtility = {}

SortUtility.__index = SortUtility

type Sortable = {
    Layer: number?,
    Rarity: string,
    Value: number,
    ID: any
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Rarities = require(ReplicatedStorage.Shared.Configuration.RarityConfig)
local Assertions = RunService:IsStudio() -- Will probably only error in studio... hopefully

local function AssertSortable(Sort)
    if Sort.Layer == nil then
        Sort.Layer = 0
    end

    if Assertions then
        assert(type(Sort.Layer) == "number", `Sortable layer is not a number got "{type(Sort.Layer)}"`)
        assert(type(Sort.Rarity) == "string", `Sortable rarity is not a string got "{type(Sort.Layer)}"`)
        assert(type(Sort.Value) == "number", `Sortable value is not number got "{type(Sort.Layer)}"`)
    end
end

local Sorts = {
    LayerAscending = function(A, B)
        return A.Layer < B.Layer
    end,

    LayerDescending = function(A, B)
        return A.Layer > B.Layer
    end,

    ValueAscending = function(A, B)
        return A.Value < B.Value
    end,

    ValueDescending = function(A, B)
        return A.Value > B.Value
    end,

    RarityAscending = function(A, B)
        return Rarities[A.Rarity].Priority < Rarities[B.Rarity].Priority
    end,

    RarityDescending = function(A, B)
        return Rarities[A.Rarity].Priority > Rarities[B.Rarity].Priority
    end
}

SortUtility.SortEnum = {
    ["LayerAscending"] = "LayerAscending",
	["LayerDescending"] = "LayerDescending",
	["ValueAscending"] = "ValueAscending",
	["ValueDescending"] = "ValueDescending",
	["RarityAscending"] = "RarityAscending",
	["RarityDescending"] = "RarityDescending",
}

SortUtility.SortFunctions = Sorts

function SortUtility:With(Data, Transformer)
    local SortList = {}
    local IDMap = {}

    for i,v in Data do
        local Sortable = Transformer(i, v)

        if Sortable then
            AssertSortable(Sortable)
            table.insert(SortList, Sortable)
            IDMap[i] = Sortable
        end
    end

    return setmetatable({
        _SortList = SortList,
        _IDToSortedMap = IDMap
    }, SortUtility)
end

function SortUtility:Debug()
	for i, v in self._SortList do
		print(`{i} - {v.ID}|L={v.Layer}|R={v.Rarity}/V={v.Value}`)
	end
end

function SortUtility:Sort(Criteria, LayerCriteria)
    LayerCriteria = LayerCriteria or "LayerAscending"

    local CriteriaFunction = assert(Sorts[Criteria], "Invalid criteria function")
    local LayerFunction = assert(Sorts[LayerCriteria], `Invalid layer criteria function {LayerCriteria}`)
    
    table.sort(self._SortList, function(A, B)
        if A.Layer == B.Layer then
            return CriteriaFunction(A, B)
        else
            return LayerFunction(A, B)
        end
    end)
end

function SortUtility:SortCustom(CriteriaFunction, LayerCriteria)
    LayerCriteria = LayerCriteria or "LayerAscending"

    local LayerFunction = assert(Sorts[LayerCriteria], `invalid layer criteria function {LayerCriteria}`)

    table.sort(self._SortList, function(a, b)
        if a.Layer == b.Layer then
            return CriteriaFunction(a, b)
        else
            return LayerFunction(a, b)
        end
    end)
end

function SortUtility:GetPosition(i)
    local Sortable = self._IDToSortedMap[i]
    local Index = table.find(self._SortList, Sortable)

	if Index == nil then
		error(`invalid element to find position of. was probably not in original db table. {i}`)
	end

	return Index
end

function SortUtility:GetSortable(i)
    local Sortable = self._IDToSortedMap[i]

	return Sortable
end

return SortUtility