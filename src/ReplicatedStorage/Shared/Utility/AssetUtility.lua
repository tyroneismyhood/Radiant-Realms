local AssetUtility = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local IsServer = RunService:IsServer()
local Assets = ReplicatedStorage.Assets
local WorldFolder
local IndexCache = {}

if IsServer then
    WorldFolder = Workspace.GameObjects.Assets
    WorldFolder.Name = "WorldAssets"
    WorldFolder.Parent = ReplicatedStorage.Assets
else
    WorldFolder = ReplicatedStorage.Assets:WaitForChild("WorldAssets")
    WorldFolder:WaitForChild("Eggs")
end

AssetUtility.WorldAssets = WorldFolder

local function Index(Folder, SearchName, Root)
    Root = Root or Folder

    if IndexCache[Root] then
        local Cached = IndexCache[Root][SearchName]

        if Cached then
            return Cached
        end
    else
        IndexCache[Root] = {}
    end

    local Got = Folder:FindFirstChild(SearchName)

    if Got then
        IndexCache[Root][SearchName] = Got

        return Got
    end

    for i,v in Folder:GetChildren() do
        if v:IsA("Folder") then
            local Found = Index(v, SearchName, Root)

            if Found then
                IndexCache[Root][SearchName] = Found

                return Found
            end
        end
    end
end

function AssetUtility:IndexWithPath(Folder, SearchPath)
    local Nodes = string.split(SearchPath, "/")
    local Direction = Folder

    for _,Node in ipairs(Nodes) do
        Direction = Direction:FindFirstChild(Node)

        if not Direction then
            error(`Could not find path {SearchPath}`)
        end
    end

    return Direction
end

local function SetupModel(Model)
    if Model and not Model:GetAttribute("Initialized") then
        for _,Descendant in ipairs(Model:GetDescendants()) do
            if Descendant:IsA("BasePart") then
                Descendant.CollisionGroup = "Pet"
                Descendant.Anchored = Descendant == Model.PrimaryPart
            end
        end

        Model:SetAttribute("Initialized", true)
    end
end

local function SetupEnemy(Model)
    if Model and not Model:GetAttribute("HipHeight") then
        local RootPart = Model:FindFirstChild("HumanoidRootPart")

        if RootPart and Model:FindFirstChild("Humanoid") ~= nil then
            local BottomOfHumanoidRootPart = Model.HumanoidRootPart.Position.Y - (Model.HumanoidRootPart.Size.Y / 2)
            local BottomOfFoot = Model["Left Leg"].Position.Y - (Model["Left Leg"].Size.Y / 2)

            Model:SetAttribute("HipHeight", BottomOfHumanoidRootPart - BottomOfFoot)
        else
            Model:SetAttribute("HipHeight", 0)
            Model:SetAttribute("NonHumanoid", true)
        end
    end
end

function AssetUtility:GenericAsset(AssetType, Name)
    local Folder = assert(WorldFolder:FindFirstChild(AssetType), `Invalid AssetType: {AssetType}`)
    local Asset = Index(Folder, Name)

    if AssetType == "Pets" then
        SetupModel(Asset)

    elseif AssetType == "Enemies" then
        SetupEnemy(Asset)
    end

    return Asset
end

function AssetUtility:Animation(Path)
    local Animation = Index(Assets.Animations, Path)

    return Animation
end

function AssetUtility:Gradient(Path)
    local Gradient = Index(Assets.Gradients, Path)

    return Gradient
end

if IsServer then
    local function InitializeEggs()
        local Folder = Instance.new("Folder")

        Folder.Name = "Eggs"
        Folder.Parent = WorldFolder

        for _,v in ipairs(CollectionService:GetTagged("Egg")) do
            local Model = v.Egg:Clone()

            Model.Name = v.Name
            Model.Parent = Folder
        end
    end

    InitializeEggs()
end

return AssetUtility