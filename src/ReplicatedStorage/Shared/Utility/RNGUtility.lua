local RNGUtility = {}

local RNG = Random.new(os.clock() * 100)
local UIDCharacters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v" }

function RNGUtility:GUID(Seed)
    local RandomSeed = Random.new(Seed)
    local Result = table.create(19) -- 16 characters + 3 dashes

    for i = 1, 16 do
        Result[i] = UIDCharacters[RandomSeed:NextInteger(1, #UIDCharacters)]
        if i == 4 or i == 8 or i == 12 then
            table.insert(Result, i + 1, "-")
        end
    end

    return table.concat(Result)
end

function RNGUtility:NextInteger(...)
    return RNG:NextInteger(...)
end

function RNGUtility:NextNumber(...)
    return RNG:NextNumber(...)
end

function RNGUtility:FromChanceFloat(Number)
    return RNG:NextNumber(0, 1) <= Number
end

function RNGUtility:FromChanceInteger(Number)
    return RNGUtility:FromChanceFloat(Number / 100)
end

function RNGUtility:RandomSign()
    return RNG:NextInteger(1, 2) == 1 and -1 or 1
end

function RNGUtility:PointInCircleVector2(Radius)
    local Theta = RNG:NextNumber(0, 2 * math.pi)
    local R = Radius * math.sqrt(RNG:NextNumber())

    return Vector2.new(R * math.cos(Theta), R * math.sin(Theta))
end

function RNGUtility:PointInPart(Part, Scale)
    Scale = Scale or 1

    local Size2 = Part.Size / 2 * Scale

    return Part.CFrame * Vector3.new(RNG:NextNumber(-Size2.X, Size2.X), RNG:NextNumber(-Size2.Y, Size2.Y), RNG:NextNumber(-Size2.Z, Size2.Z))
end

function RNGUtility:PointInCircleVector3(Radius)
    while true do
        local Position = Vector3.new(RNG:NextNumber(-Radius, Radius), 0, RNG:NextNumber(-Radius, Radius))

        if Position.Magnitude < Radius then
            return Position
        end
    end
end

function RNGUtility:UnitVector2()
    local V3 = RNG:NextUnitVector()

    return Vector2.new(V3.X, V3.Y).Unit
end

function RNGUtility:UnitVector3()
    return RNG:NextUnitVector()
end

local function GetWeight(v, WeightIndex)
    return math.max(0, WeightIndex and v[WeightIndex] or v)
end

function RNGUtility:RandomArrayValue(Items)
	return Items[RNG:NextInteger(1, #Items)]
end

function RNGUtility:RandomChild(Parent)
	return RNGUtility:RandomArrayValue(Parent:GetChildren())
end

function RNGUtility.SelectRandom(Items, WeightIndex)
    local TotalWeight = RNGUtility:SumWeight(Items, WeightIndex)
    local Pick = RNG:NextNumber(0, TotalWeight)

    for Item, Weight in pairs(Items) do
        Weight = GetWeight(Weight, WeightIndex)
        
        if Pick <= Weight then
            return Item
        else
            Pick = Pick - Weight
        end
    end

    error("Invalid table to select from")
end

function RNGUtility:SumWeight(Items, WeightIndex)
	local Sum = 0

	for _, Weight in Items do
		Sum += GetWeight(Weight, WeightIndex)
	end

	return Sum
end

function RNGUtility:GetChance(Index, Items, WeightIndex)
	local Weight = Items[Index]

	if not Weight then
		return 0
	end

	return GetWeight(Weight, WeightIndex) / RNGUtility:SumWeight(Items, WeightIndex) * 100
end

return RNGUtility