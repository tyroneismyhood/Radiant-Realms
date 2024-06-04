local TableUtility = {}

-- Returns if all values in A are in B
function TableUtility:EqualArray(A, B)
    if #A ~= #B then
        return false
    end

    for i, v in pairs(A) do
        if B[i] ~= v then
            return false
        end
    end

    return true
end

function TableUtility:CloneTable(Table, Lookup)
	Lookup = Lookup or {}

    if Lookup[Table] then
        return Lookup[Table]
    else
        local ClonedTable = {}

        Lookup[Table] = ClonedTable

        for i, v in pairs(Table) do
            i = type(i) == "table" and TableUtility:CloneTable(i, Lookup) or i
            v = type(v) == "table" and TableUtility:CloneTable(v, Lookup) or v
            ClonedTable[i] = v
        end
        
        return ClonedTable
    end
end

-- Returns a new table where all values in this table are in the same keys but are mutated by the mutate function
function TableUtility:Transform(Table, Mutate)
    assert(type(Mutate) == "function", "Mutate must be a function")
    
    local Transformed = {}

    for i, v in pairs(Table) do
        Transformed[i] = Mutate(v)
    end

    return Transformed
end

-- Shallow match, returns true if all keys in A and B are in both tables
function TableUtility:Equal(A, B)
    for k in pairs(A) do
        if B[k] ~= A[k] then
            return false
        end
    end

    for k in pairs(B) do
        if A[k] ~= B[k] then
            return false
        end
    end

    return true
end

-- Creates a new table with keys and values filtered from the original with predicate. If table is nil just returns a new table
function TableUtility:Filter(Table, Predicate)
    if not Table then
        return {}
    end
    
    local Filtered = {}

    for i,v in Table do
        if Predicate(i, v) then
            Filtered[i] = v
        end
    end

    return Filtered
end

-- Creates a new table with just the keys filtered from the original with predicate
function TableUtility:FilterKeys(Table, Predicate)
    if not Table then
        return {}
    end

    local Filtered = {}

    for i,v in Table do
        if Predicate(i, v) then
            table.insert(Filtered, i)
        end
    end

    return Filtered
end

function TableUtility:Sum(Array)
    local Number = 0

    for _,v in Array do
        Number += v
    end

    return Number
end

function TableUtility:Join(Table, ...)
    for _, Values in ipairs({...}) do
        for _, v in ipairs(Values) do
            table.insert(Table, v)
        end
    end

    return Table
end

function TableUtility:Merge(Table, ...)
    for _, Values in ipairs({...}) do
        for i, v in pairs(Values) do
            Table[i] = v
        end
    end

    return Table
end

function TableUtility:Last(Array)
    return Array[#Array]
end

function TableUtility:Length(Table)
    local Number = 0

    for i,v in Table do
        Number += 1
    end

    return Number
end

-- Returns a table such that {[A] = v, [B] = v} is returned as {A, B}
function TableUtility:Keys(Table)
    local Keys = {}

    for i,v in Table do
        table.insert(Keys, i)
    end

    return Keys
end

function TableUtility:Shuffle(Table)
    for i = #Table, 2, -1 do
        local Randomized = math.random(i)

        Table[i] = Table[Randomized]
        Table[Randomized] = Table[i]
    end

    return Table
end

-- Returns a table such that {[A] = v} = {V} (probably don't use this for arrays!)
function TableUtility:Values(...)
    local Values = {...}

    for _,Table in {...} do
        for _,Value in Table do
            table.insert(Values, Value)
        end
    end

    return Values
end

-- Returns a table such that {[A] = v, [B] = v} is returned as {{A, v}, {B, v}}
function TableUtility:KeysAndValues(Table)
    local Result = {}

    for k, v in pairs(Table) do
        table.insert(Result, {k, v})
    end
    
    return Result
end

local function SortedKeys(Table)
    local Keys = TableUtility:Keys(Table)

    table.sort(Keys, function(A, B)
        return tostring(A) < tostring(B)
    end)

    return Keys
end

function TableUtility:ToString(Table, Depth, ScannedTables)
    Depth = Depth or 1
    ScannedTables = ScannedTables or {[Table] = true}
    
    local Result = "{"
    local Tabs = string.rep("\t", Depth)

    for _,i in SortedKeys(Table) do
        local v = Table[i]
        local ValueString

        if type(v) == "table" then
            if ScannedTables[v] then
                ValueString = `*cyclic reference detected {v}*`
            else
                ScannedTables[v] = true
                ValueString = TableUtility:ToString(v, Depth + 1, ScannedTables)
            end
        else
            ValueString = tostring(v)
        end

        local String = `\n{Tabs}[{i}] = {ValueString};`

        Result ..= String
    end

    Result ..= `\n{string.rep("\t", Depth - 1)}}`

    return Result
end

return TableUtility