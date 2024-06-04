local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local AtomicTags = {"Egg", "NPC", "Pet", "Leaderboard", "Chest", "Machine"}

local function OnAtomicModelAdded(InstanceObject)
    if not InstanceObject:IsA("Model") then
        warn("Instance with an Atomic linked tag is not a model! Location = " .. {InstanceObject:GetFullName()})
    end

    if InstanceObject:IsDescendantOf(Workspace) then
        InstanceObject.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
    end
end

for _,TagName in AtomicTags do
    for _,Model in CollectionService:GetTagged(TagName) do
        OnAtomicModelAdded(Model)
    end

    CollectionService:GetInstanceAddedSignal(TagName):Connect(OnAtomicModelAdded)
end

local StartTime = os.clock()

Knit.AddServices(script.Parent.Services)

Knit.Start()
    :andThen(function()
    local Delta = os.clock() - StartTime

    print(string.format("[KnitServer]: started in %.6gs", Delta))
end):catch(warn)