--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const remote = ReplicatedStorage:WaitForChild("NerpDemo") :: UnreliableRemoteEvent
const withoutNerp = Workspace:WaitForChild("without_nerp") :: BasePart

const RATE = 20
const STEP = 1 / RATE
const RADIUS = 20
const SPEED = 1.2

const t0 = Workspace:GetServerTimeNow()
local last = 0

while true do
	task.wait(STEP)
	const now = Workspace:GetServerTimeNow()
	const elapsed = now - t0
	const angle = elapsed * SPEED

	const cf = CFrame.new(Vector3.new(math.cos(angle) * RADIUS, 6, math.sin(angle) * RADIUS))

	withoutNerp.CFrame = cf

	if now - last >= STEP then
		last = now
		remote:FireAllClients(now, cf)
	end
end
