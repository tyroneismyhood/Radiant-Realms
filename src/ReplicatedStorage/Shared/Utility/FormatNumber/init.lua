local FormatNumber = {
	ConversionTable = {}
}

local Suffixes = {
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx", 
	"Sp", 
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Od",
	"Nd",
	"V",
	"Uv",
	"Dv",
	"Tv",
	"Qav",
	"Qiv",
	"Sxv",
	"Spv",
	"Ov",
	"Nv",
	"Tt",
}

local RomanNumerals = {
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" },
}

local TimeUnits = {
	{ "s", 1 },
	{ "m", 60 },
	{ "h", 60 * 60 },
	{ "d", 60 * 60 * 24 },
	{ "w", 60 * 60 * 24 * 7 },
	{ "mo", 60 * 60 * 24 * 30 },
}

local RomanCache = {}

function FormatNumber:Percent(Number, DecimalPlace)
    DecimalPlace = 10 ^ (DecimalPlace or 0)

    return string.format("%." .. DecimalPlace .. "f%%", Number * 100)
end

function FormatNumber:Commas(Number)
    return tostring(Number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

function FormatNumber:RomanNumerals(Number)
    Number = math.floor(Number)

    if RomanCache[Number] then
        return RomanCache[Number]
    end

    local Result = ""

    for _, pair in ipairs(RomanNumerals) do
        local Value, Numeral = unpack(pair)

        while Number >= Value do
            Result = Result .. Numeral
            Number = Number - Value
        end
    end

    RomanCache[Number] = Result

    return Result
end

function FormatNumber:ShortClockString(Seconds, IncludeFraction)
    local LargestFactor, LargestUnitName = 1, "s"

    for _,Unit in ipairs(TimeUnits) do
        if Seconds >= Unit[2] then
            LargestFactor, LargestUnitName = Unit[2], Unit[1]
        else
            break
        end
    end

    local UnitValue = math.floor(Seconds / LargestFactor)
    local DecimalPlace = ""

    if IncludeFraction and UnitValue < 1 and LargestFactor == 1 then
        DecimalPlace = "." .. math.floor((Seconds % LargestFactor) * 10)
    end

    return string.format("%d%s%s", UnitValue, DecimalPlace, LargestUnitName)
end

function FormatNumber:Chance(Chance)
	if Chance >= 1 then
		return string.format("%.1f%%", Chance)
	else
		local Exponent = math.floor(math.log10(Chance))
		local Mantissa = Chance / 10 ^ Exponent

		return string.format("%.2f", Mantissa * 100) .. "e" .. Exponent .. "%"
	end
end

function FormatNumber:ToClockString(Seconds)
	local Seconds = tonumber(Seconds)

	if Seconds <= 0 then
		return "00:00:00"
	else
		local Hours = string.format("%02.f", math.floor(Seconds / 3600))
		local Mins = string.format("%02.f", math.floor(Seconds / 60 - (Hours * 60)))
		local Secs = string.format("%02.f", math.floor(Seconds - Hours * 3600 - Mins * 60))

		return Hours .. ":" .. Mins .. ":" .. Secs
	end
end

function FormatNumber:AdaptiveClockString(Seconds, Digits, ForcePlaces)
	Seconds = math.max(Seconds, 0)

	if (Digits and Seconds < 60) or (not Digits and Seconds <= 1) then
		return `{math.floor(Seconds)}s`
	end

	ForcePlaces = 1

	local Result = ""
	local Cascade = false

	for i = #TimeUnits, 1, -1 do
		local Unit = TimeUnits[i]
		local UnitName = Unit[1]
		local UnitValue = Unit[2]

		if Seconds >= UnitValue or Cascade or (i <= ForcePlaces) then
			Cascade = true
			
			local NumberUnits = math.floor(Seconds / UnitValue)

			Seconds = Seconds % UnitValue

			if Digits then
				Result = Result .. string.format("%02.f", NumberUnits) .. ":"
			else
				Result = Result .. NumberUnits .. UnitName .. " "
			end
		end
	end
	
	return Result:sub(1, -2)
end

function FormatNumber:Short(Number, IncludeSmallNumberDecimals)
    if Number < 1000 then
        if IncludeSmallNumberDecimals and Number < 10 then
            return string.format("%.1f", Number)
        else
            return tostring(math.floor(Number))
        end
    end

    local Index = math.floor(math.log10(Number) / 3)
    local ScaledNumber = Number / 1000 ^ Index

    return string.format("%.2f%s", ScaledNumber, Suffixes[Index])
end

function FormatNumber:HHMMSS(Seconds)
	Seconds = tonumber(Seconds)

	if Seconds <= 0 then
		return "00:00:00"
	else
		local Hours = math.floor(Seconds / 3600)
		local Mins = math.floor(Seconds / 60 - (Hours * 60))
		local Secs = math.floor(Seconds - Hours * 3600 - Mins * 60)

		return string.format("%02.f:%02.f:%02.f", Hours, Mins, Secs)
	end
end

function FormatNumber:SixFigs(Number, SF)
	return string.format("%." .. SF .. "g", Number)
end

function FormatNumber:DecimalPlaces(Number, DP)
	local x = 10 ^ DP

	return math.floor(Number * x) / x
end

function FormatNumber:SixDP(Number, DP)
	DP = DP or 2

	local Decimals = Number % 1

	if Decimals < 0.000001 then
		return tostring(math.floor(Number))
	end

	return math.floor(Number) .. "." .. self:SixFigs(Decimals, DP):sub(3)
end

function FormatNumber:ConvertCurrency(Value)
	if tonumber(Value) then
		return tonumber(Value)
	end

	if self.ConversionTable[Value] ~= nil then
		return self.ConversionTable[Value]
	end

	local Value1 = nil
	local Value2 = string.find(Value, "e%+")

	if Value2 ~= nil then
		Value1 = tonumber(string.sub(tostring(Value), 1, 1)) * 10 ^ tonumber(string.sub(tostring(Value), Value2 + 2))
	else
		local Value3, Value4, Value5 = pairs(Suffixes)

		while true do
			local Value6, Value7 = Value3(Value4, Value5)

			if not Value6 then
				break
			end

			Value5 = Value6

			if string.find(Value, Value7) ~= nil then
				if string.sub(Value, string.len(Value) - string.len(Value7) + 1) == Value7 then
					Value1 = tonumber((string.sub(Value, 1, string.len(Value) - string.len(Value7)))) * 10 ^ (3 * Value6)
				end
			end
		end
	end

	self.ConversionTable[Value] = Value1

	return Value1
end

return FormatNumber