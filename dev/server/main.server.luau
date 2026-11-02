--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const Nerp = require(ReplicatedStorage:WaitForChild("Nerp"))

const remote = ReplicatedStorage:WaitForChild("NerpDemo") :: UnreliableRemoteEvent
const withNerp = workspace:WaitForChild("with_nerp") :: BasePart
const withoutNerp = Workspace:WaitForChild("without_nerp") :: BasePart

const RATE = 20
const STEP = 1 / RATE
const RADIUS = 10
const SPEED = 1.2

const GAP_EVERY = 6
const GAP_MS = 0.25

const history = Nerp.history()

const t0 = Workspace:GetServerTimeNow()
local last = 0
local gap_until = 0

while true do
	task.wait(STEP)
	const now = Workspace:GetServerTimeNow()
	const elapsed = now - t0
	const angle = elapsed * SPEED

	const cf = CFrame.new(Vector3.new(math.cos(angle) * RADIUS, 6, math.sin(angle) * RADIUS))

	withoutNerp.CFrame = cf

	history:record(withNerp:GetFullName(), now, cf)

	if now - last >= STEP and now >= gap_until then
		last = now
		remote:FireAllClients(now, cf)

		const cycle = elapsed % GAP_EVERY
		if cycle < STEP and elapsed > GAP_EVERY then
			gap_until = now + GAP_MS
			print(string.format("nerp demo: dropping the feed for %.0fms", GAP_MS * 1000))
		end
	end
end
