local Utilities = {}

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SecondsPerGameHour = 60

Utilities.SecondsPerGameHour = SecondsPerGameHour

if RunService:IsServer() then
    function Utilities:GetOutlineContainer(Object)
        local Container = Object:FindFirstChild("OutlineContainer")
        if Container then
            return Container
        end
    
        Container = Instance.new("Model")
        Container.Name = "OutlineContainer"
        Container.Parent = Object
        
        local Highlight = Instance.new("Highlight")

        Highlight.OutlineTransparency = 0
        Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        Highlight.FillTransparency = 1
        Highlight.Adornee = Container
        Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        Highlight.Parent = Container
    
        return Container
    end
end

function Utilities:GetClockTime()
    local GameTick = Workspace:GetServerTimeNow()

    return (GameTick / SecondsPerGameHour) % 24
end

function Utilities:RealTimeUntilNextClockTime(DeltaClock)
    local CurrentClock = self:GetClockTime()
    local TimeDifference = DeltaClock - CurrentClock

    return (TimeDifference >= 0 and TimeDifference or 24 + TimeDifference) * SecondsPerGameHour
end

function Utilities:GetAlternateGradient(Gradient)
    return Gradient
end

function Utilities:HoursMins(HourAndMinString)
    local Left, Right = unpack(HourAndMinString:split(":"))

    return tonumber(Left), tonumber(Right)
end

function Utilities:ReadTimeTable(Table)
    local Day = Table[1]
    local Month = Table[2]
    local Year = Table[3]
    local Hours, Mins = Utilities:HoursMins(Table[4])
    local DateTimeValue = DateTime.fromUniversalTime(Year, Month, Day, Hours, Mins, 0, 0)

    return DateTimeValue
end

function Utilities:FloorUnitVector(Vector3Value)
    return Vector3.new(Vector3Value.X, 0, Vector3Value.Z).Unit
end

function Utilities:ResolvePathModel(Time, Seconds, Path)
    local Sorted = Path:GetChildren()

    table.sort(Sorted, function(A, B)
        return tonumber(A.Name) < tonumber(B.Name)
    end)

    local Nodes = {}
    local TotalTime = 0

    for i = 1, #Sorted do
        local Position = Sorted[i].Position
        local NextPosition = Sorted[i % #Sorted + 1].Position
        local DistanceToNext = (Position - NextPosition).Magnitude
        local TimeOnThisNode = DistanceToNext / Seconds

        Nodes[i] = {Time = TimeOnThisNode, Position = Position, NextPosition = NextPosition}
        TotalTime += TimeOnThisNode
    end

    -- Calculate position from node times
    local Point = Time % TotalTime
    local Aggregate = 0

    for i, Node in ipairs(Nodes) do
        Aggregate += Node.Time

        if Point < Aggregate then
            local Alpha = (Point - (Aggregate - Node.Time)) / Node.Time
            
            return Node.Position:Lerp(Node.NextPosition, Alpha), CFrame.lookAt(Node.Position, Node.NextPosition).Rotation
        end
    end

    error("Invalid path")
end

-- Speed is angle based not distance!
function Utilities:ResolvePathCircle(Origin, Time, Seconds, Radius)
    local Position = Origin + Vector3.new(math.sin(math.rad(Time * Seconds)) * Radius, 0, math.cos(math.rad(Time * Seconds)) * Radius)

    return Position, (CFrame.lookAt(Position, Origin) * CFrame.Angles(0, -math.pi / 2, 0) * CFrame.Angles(math.rad(7.5), 0, math.rad(12))).Rotation
end

function Utilities:ResolvePath(Path, Time, Seconds)
    if not Path then
        return
    end

    local CirclePart

    if Path:IsA("BasePart") then
        CirclePart = Path

    elseif Path:IsA("Model") and #Path:GetChildren() == 1 then
        CirclePart = Path.PrimaryPart
    end

    if CirclePart then
        return Utilities:ResolvePathCircle(Time, Seconds * 0.75, CirclePart)
    else
        return Utilities:ResolvePathModel(Time, Seconds, Path)
    end
end

return Utilities