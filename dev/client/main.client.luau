--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const Nerp = require(ReplicatedStorage:WaitForChild("Nerp"))

const remote = ReplicatedStorage:WaitForChild("NerpDemo") :: UnreliableRemoteEvent
const withNerp = Workspace:WaitForChild("with_nerp") :: BasePart

const demo = Nerp.new(20, "LOW_LATENCY", { extrapolate = 0.08 })
demo:track(withNerp)
demo:start()

remote.OnClientEvent:Connect(function(t: number, cf: CFrame)
	demo:feed(withNerp:GetFullName(), { { t = t, cf = cf } })
end)

const history = Nerp.history()

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

		const now = Workspace:GetServerTimeNow()
		history:record("probe", now, withNerp.CFrame)
		const rewound = history:rewind(now - 0.12)
		print(string.format("history: %d entries aat t-120ms", #rewound))
	end
end)
