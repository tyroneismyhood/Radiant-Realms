local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Notifications = require(script.Notifications)
local Prompts = require(script.Prompts)

local MessageController = Knit.CreateController({
	Name = "MessageController",
})

function MessageController:Notify(Style, Content, Color)
    Notifications.Notify(Style, Content, Color)
end

function MessageController:Prompt(MessageData)
    return Prompts.Prompt(MessageData)
end

function MessageController:KnitStart()
    task.spawn(function()
        while true do
            self:Notify(1, "This is a test notification", Color3.fromRGB(255, 255, 255))
            task.wait(6)
        end
    end)
end

function MessageController:KnitInit()

end

return MessageController
