--!strict

const types = require("./types")

const rig = {}
rig.__index = rig

export type Rig = typeof(setmetatable(
	{} :: {
		_world: WorldRoot,
		_bulkParts: { BasePart },
		_bulkFrames: { CFrame },
	},
	rig
))

const function check_welded(root: BasePart, model: Model): ()
	local welded = 0
	for _, descendant in model:GetDescendants() do
		if
			descendant:IsA("WeldConstraint")
			or descendant:IsA("Weld")
			or descendant:IsA("Motor6D")
		then
			const part0 = (descendant :: any).Part0 :: BasePart?
			const part1 = (descendant :: any).Part1 :: BasePart?
			if part0 == root or part1 == root then
				welded += 1
			end
		end
	end
	if welded == 0 then
		error(
			`Nerp: model "{model:GetFullName()}" has no weld to its root part. Weld the model before tracking it.`,
			0
		)
	end
end

function rig.new(world: WorldRoot, capacity: number): Rig
	const parts: { BasePart } = {}
	const frames: { CFrame } = {}
	for i = 1, capacity do
		frames[i] = CFrame.identity
	end

	const self: Rig = (
		setmetatable({
			_world = world,
			_bulkParts = parts,
			_bulkFrames = frames,
		}, rig) :: any
	) :: Rig
	return self
end

function rig.attach(self: any, instance: BasePart | Model, root: BasePart?): types.RigKind
	if instance:IsA("BasePart") then
		return "part"
	end

	const model = instance :: Model
	const resolved: BasePart? = root or model.PrimaryPart
	if resolved == nil then
		error(
			`Nerp: model "{model:GetFullName()}" has no primaryPart, set one or pass the root in the track options`,
			0
		)
	end
	check_welded(resolved :: BasePart, model)
	return "model"
end

function rig.apply(self: any, target: types.Target, cf: CFrame)
	if target.kind == "part" then
		const part = target.instance :: BasePart
		part.CFrame = cf
		return
	end

	const root = target.root
	if root == nil then
		return
	end
	root.CFrame = cf
end

function rig.applyBulk(self: Rig, targets: { types.Target }, frames: { CFrame }): number
	local count = 0
	for i, target in targets do
		if target.kind ~= "part" then
			continue
		end
		count += 1
		self._bulkParts[count] = target.instance :: BasePart
		self._bulkFrames[count] = frames[i]
	end

	while #self._bulkParts > count do
		self._bulkParts[#self._bulkParts] = nil
	end
	while #self._bulkFrames > count do
		self._bulkFrames[#self._bulkFrames] = nil
	end

	if count > 0 then
		self._world:BulkMoveTo(
			self._bulkParts,
			self._bulkFrames,
			Enum.BulkMoveMode.FireCFrameChanged
		)
	end
	return count
end

return table.freeze({
	new = rig.new,
	attach = rig.attach,
	apply = rig.apply,
})
