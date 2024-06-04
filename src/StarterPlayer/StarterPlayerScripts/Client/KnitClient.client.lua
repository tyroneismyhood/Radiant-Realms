local ScriptStartTime = os.clock()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local ReplicaController = require(ReplicatedStorage.Client.ReplicaController)
local ClientGlobals = require(ReplicatedStorage.Client.ClientGlobals)

do
	local StartTime = os.clock()
	local Thread = coroutine.running()

	ReplicaController.ReplicaOfClassCreated("PlayerDataV1", function(Replica)
		ClientGlobals.Replica = Replica
		coroutine.resume(Thread)
	end)

	ReplicaController.RequestData()
	coroutine.yield()

	local Delta = os.clock() - StartTime

	print(string.format("[KnitClient]: got replica in %.6gs", Delta))
end

-- Init
do
	print("?")
	Knit.AddControllers(script.Parent.Controllers.Main)

	Knit.Start():andThen(function()
		print("ok")
        local Delta = os.clock() - ScriptStartTime

        print(string.format("[KnitClient]: started in %.6gs", Delta))
    end):catch(warn)
end