local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local DataUtility = require(ServerStorage.Modules.DataUtility)
local Utilities = require(ReplicatedStorage.Shared.Utility.Utility)
local ModelUtility = require(ServerStorage.Modules.ModelUtility)
local AssetUtility = require(ReplicatedStorage.Shared.Utility.AssetUtility)

local function HandleSwordEquipping(Player)
    local Character = Player.Character

    if not Character then return end

    local Profile = DataUtility:GetProfile(Player)
    
    if not Profile then return end

    local SwordData = Profile.Data.Swords[Profile.Data.EquippedSword]

    if SwordData then
        local SwordFolder = Utilities:GetOutlineContainer(Character)
        local SwordPath = `EquippedSword1`
        local Equipped = SwordFolder:FindFirstChild(SwordPath)

        if Equipped then
            Equipped:Destroy()
        end

        if not SwordData.Name then return end

        local Sword = AssetUtility:GenericAsset("Swords", SwordData.Name):Clone()

        print(SwordFolder)
        print(SwordFolder.Parent)

        Sword.Name = SwordPath
        Sword.Parent = SwordFolder

        if SwordData.Grade then
            local GradeFX = ReplicatedStorage.Assets.Effects.BladeEffects:FindFirstChild(SwordData.Grade)

            if GradeFX then
                for _,v in ipairs(GradeFX:GetChildren()) do
                    v:Clone().Parent = Sword.Blade
                end
            end
        end

        Sword:ScaleTo(Sword:GetScale())
        ModelUtility:AttachTrailToSword(Sword, ReplicatedStorage.Assets.Effects.SwingTrail)
        ModelUtility:SetupSwordPhysics(Sword)
        ModelUtility:WeldSwordToHand(Sword, Character, "RightHand")
    end
end

return HandleSwordEquipping