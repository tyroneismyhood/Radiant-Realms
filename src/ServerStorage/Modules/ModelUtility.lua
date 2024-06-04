local ModelUtility = {}

function ModelUtility:OnWeldChanged(Weld, Recalculate)
    if not (Weld and Recalculate) then
        warn("Invalid Weld or Recalculate function provided to OnWeldChanged.")
        return
    end

    Recalculate()
    Weld:GetPropertyChangedSignal("Part0"):Connect(Recalculate)
    Weld:GetPropertyChangedSignal("Part1"):Connect(Recalculate)
end

function ModelUtility:AttachTrailToSword(Sword, TrailAsset)
    local BladePart = Sword:FindFirstChild("Blade")

    if not BladePart then
        return
    end

    local SizeZ = BladePart.Size.Z / 2
    local Attachment0 = Instance.new("Attachment", BladePart)
    local Attachment1 = Instance.new("Attachment", BladePart)
    local Trail = TrailAsset:Clone()

    Attachment0.CFrame = CFrame.new(0, 0, -SizeZ)
    Attachment1.CFrame = CFrame.new(0, 0, SizeZ)
    Trail.Attachment0 = Attachment0
    Trail.Attachment1 = Attachment1
    Trail.Enabled = false
    Trail.Parent = Sword
end


function ModelUtility:AttachTrailToObject(Object, TrailAsset, AttachmentPoints)
    local BladePart = Object:FindFirstChild(AttachmentPoints.BladePartName or "Blade")
    
    if not BladePart then
        warn("BladePart not found in the provided Object.")
        return
    end

    local Trail = TrailAsset:Clone()
    Trail.Enabled = true

    for i, point in ipairs(AttachmentPoints) do
        local attachment = Instance.new("Attachment", BladePart)
        attachment.CFrame = CFrame.new(point.Position)
        Trail["Attachment" .. i] = attachment
    end

    Trail.Parent = BladePart
end

function ModelUtility:SetupSwordPhysics(Sword)
    for _, v in ipairs(Sword:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Massless = true
            v.Anchored = false

            if v ~= Sword.PrimaryPart then
                local wc = Instance.new("WeldConstraint")

                wc.Part0 = v
                wc.Part1 = Sword.PrimaryPart
                wc.Parent = v
            end
        end
    end
end

function ModelUtility:WeldSwordToHand(Sword, Character, HandName)
    local Hand = Character:FindFirstChild(HandName)
    local PrimaryPart = Sword.PrimaryPart

    if not (Hand and PrimaryPart) then
        return
    end

    local GripWeld = Instance.new("Weld")
    
    GripWeld.Name = "Grip"
    GripWeld.Part0 = Hand
    GripWeld.Part1 = PrimaryPart
    GripWeld.Parent = Sword
end

return ModelUtility