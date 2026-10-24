--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const Nerp = require(ReplicatedStorage:WaitForChild("Nerp"))

const remote = ReplicatedStorage:WaitForChild("NerpDemo") :: UnreliableRemoteEvent
const withNerp = Workspace:WaitForChild("with_nerp") :: BasePart

const demo = Nerp.new(20, "LOW_LATENCY")
demo:track(withNerp)
demo:start()

remote.OnClientEvent:Connect(function(t: number, cf: CFrame)
	demo:feed(withNerp:GetFullName(), { { t = t, cf = cf } })
end)

task.spawn(function()
	while true do
		task.wait(1)
		const s = demo:stats()
		print(
			string.format(
				"targets=%d applied=%d held=%d stale=%d render=%.3f newest=%.3f delay=%.3f",
				s.targets,
				s.applied,
				s.held,
				s.stale,
				s.renderTime,
				s.newest,
				s.delay
			)
		)
	end
end)
