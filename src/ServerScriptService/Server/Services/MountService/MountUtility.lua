local MountUtility = {}

function MountUtility.SetupPart(Part, MainPart, Character)
    if Part.Name == "Collider" then
        Part.CollisionGroup = "Player"
        Part.CanCollide = true
    else
        Part.CanCollide = false
        Part.CanQuery = false
    end

    if Part ~= MainPart and Part.Anchored then
        local WeldConstraint = Instance.new("WeldConstraint")
        WeldConstraint.Part0 = Part
        WeldConstraint.Part1 = MainPart
        WeldConstraint.Parent = Part
        Part.Anchored = false
    end

    Part.Anchored = false
    Part.Massless = true
end

function MountUtility.SetupWeld(MainPart, HumanoidRootPart)
    local Weld = Instance.new("Weld")
    Weld.Part0 = MainPart
    Weld.Part1 = HumanoidRootPart
    Weld.C0 = CFrame.new(0, HumanoidRootPart.Size.Y / 2 + HumanoidRootPart.Parent.Humanoid.HipHeight, 0)
    Weld.C1 = CFrame.new(0, MainPart.Size.Y / 2, 0):Inverse()
    Weld.Parent = MainPart
end

function MountUtility.SetupMountModel(Model, MountData, Character)
    local MainPart = Model.PrimaryPart

    if MountData.FallResistance then
        local Force = Instance.new("VectorForce")
        Force.ApplyAtCenterOfMass = true
        Force.Attachment0 = Character.HumanoidRootPart.RootRigAttachment
        Force.RelativeTo = Enum.ActuatorRelativeTo.World
        Force.Force = Vector3.new(0, Character.HumanoidRootPart.AssemblyMass * workspace.Gravity * MountData.FallResistance, 0)
        Force.Parent = Model
    end

    for _, v in ipairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            MountUtility.SetupPart(v, MainPart, Character)
        end
    end

    MainPart.Anchored = false
    MountUtility.SetupWeld(MainPart, Character.HumanoidRootPart)
end

return MountUtility