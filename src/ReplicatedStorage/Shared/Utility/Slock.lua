local Slock = {}

Slock.__index = Slock

function Slock.New(Changed)
    local self = setmetatable({
        Callback = Changed,
        State = {}
    }, Slock)

    local LastCall = false

    self.OnChanged = function()
        -- Only invokes from false > true or false > false. Will never repeat false > false and true > true
        local IsActive = self:IsActive()

        if IsActive ~= LastCall then
            LastCall = IsActive
            task.spawn(self.Callback, IsActive)
        end
    end

    return self
end

function Slock:IsActive()
    return self.State[1] ~= nil
end

function Slock:Add(Variable)
    local Index = table.find(self.State, Variable)

    if not Index then
        table.insert(self.State, Variable)
        self.OnChanged()
    end
end

function Slock:Remove(Variable)
    local Index = table.find(self.State, Variable)

    if Index then
        table.remove(self.State, Index)
        self.OnChanged()
    end
end

return Slock