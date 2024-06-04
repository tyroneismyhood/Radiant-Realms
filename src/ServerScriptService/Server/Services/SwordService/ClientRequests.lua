local ServerStorage = game:GetService("ServerStorage")

local ClientRequests = {}

local DataUtility = require(ServerStorage.Modules.DataUtility)
local HandleSwordEquipping = require(script.Parent.HandleSwordEquipping)

function ClientRequests:SetLocked(Player, SwordID, Locked)
    local Profile = DataUtility:GetProfile(Player)

    if Profile.Data.Swords[SwordID] then
        Profile.Data.Swords[SwordID].Locked = Locked or nil
        DataUtility:Replicate(Player, "Swords")
    end
end

function ClientRequests:Equip(Player, SwordID)
    local Profile = DataUtility:GetProfile(Player)

    if Profile.Data.Swords[SwordID] then
        Profile.Data.EquippedSword = SwordID
        HandleSwordEquipping(Player)

        return true
    end

    return false
end

function ClientRequests:Unequip(Player, SwordID)
    local Profile = DataUtility:GetProfile(Player)

    if Profile and Profile.Data.EquippedSword == SwordID then
        Profile.Data.EquippedSword = nil
        HandleSwordEquipping(Player)
    end
end

return ClientRequests
