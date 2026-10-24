--!strict

const RunService = game:GetService("RunService")

const types = require("./types")
const clock = require("./clock")
const buffer = require("./buffer")
const rig = require("./rig")
const measure = require("./measure")

const store = {}
store.__index = store

export type Store = typeof(setmetatable(
	{} :: {
		_clock: clock.Clock,
		_rig: rig.Rig,
		_measure: measure.Measure,
		_targets: { [string]: types.Target },
		_order: { types.Target },
		_frames: { CFrame },
		_outs: { types.Output },
		_conn: RBXScriptConnection?,
		_rate: number,
		_preset: types.DelayPreset,
	},
	store
))

const RATE = 20

const DELAY: types.DelayPreset = "SMOOTH"

const BULK_THRESHOLD = 8

const function new_id(instance: Instance): string
	return instance:GetFullName()
end

function store.new(rate: number?, preset: types.DelayPreset?): Store
	const self: Store = (
		setmetatable({
			_clock = clock.new(rate or RATE, preset or DELAY),
			_rig = rig.new(workspace, BULK_THRESHOLD),
			_measure = measure.new(),
			_targets = {},
			_order = {},
			_frames = {},
			_outs = {},
			_conn = nil,
			_rate = rate or RATE,
			_preset = preset or DELAY,
		}, store) :: any
	) :: Store
	return self
end

function store.track(
	self: Store,
	instance: BasePart | Model,
	options: types.TrackOptions?
): types.Target
	const id = new_id(instance)
	const existing = self._targets[id]
	if existing ~= nil then
		return existing
	end

	const opts: types.TrackOptions = options or {}
	const kind: types.RigKind = self._rig:attach(instance, opts.root)
	const root: BasePart? = if kind == "model"
		then (opts.root or (instance :: Model).PrimaryPart)
		else nil

	const target: types.Target = {
		id = id,
		instance = instance,
		kind = kind,
		apply = if opts.apply == nil then true else opts.apply :: boolean,
		root = root,
		buffer = buffer.new(),
	}
	self._targets[id] = target
	table.insert(self._order, target)
	table.insert(self._frames, CFrame.identity)
	return target
end

function store.untrack(self: Store, target: types.Target)
	self._targets[target.id] = nil
	for i = #self._order, 1, -1 do
		if self._order[i] == target then
			table.remove(self._order, i)
			table.remove(self._frames, i)
			break
		end
	end
end

function store.feed(self: Store, id: string, samples: { types.Sample })
	const target = self._targets[id]
	if target == nil then
		return
	end
	for _, sample in samples do
		target.buffer:push(sample.t, sample.cf)
	end
end

function store.stats(self: Store): types.Stats
	const count = #self._order
	const newest = if count > 0 then self._order[1].buffer:newest() else 0
	return self._measure:snapshot(count, self._clock:now(), newest, self._clock:delay())
end

const function step(self: Store, dt: number)
	const count = #self._order
	if count == 0 then
		return
	end

	local newest = 0
	for _, target in self._order do
		const n = target.buffer:newest()
		if n > newest then
			newest = n
		end
	end

	const render_time, stale = self._clock:advance(dt, newest)
	if stale then
		self._measure:stale()
	end

	local parts = 0
	for i, target in self._order do
		const after = target.buffer:after(render_time)
		const before = target.buffer:before(render_time)

		if after ~= nil and before ~= nil and after.t > before.t then
			const span = after.t - before.t
			const alpha = (render_time - before.t) / span
			self._frames[i] = before.cf:Lerp(after.cf, alpha)
		elseif after ~= nil then
			self._frames[i] = after.cf
		elseif before ~= nil then
			self._frames[i] = before.cf
		else
			self._measure:hold()
			continue
		end

		self._measure:applied()

		if not target.apply then
			continue
		end

		if target.kind == "part" then
			parts += 1
		else
			self._rig:apply(target, self._frames[i])
		end
	end

	if parts > 0 then
		self._rig:applyBulk(self._order, self._frames)
	end
end

function store.start(self: Store)
	if self._conn ~= nil then
		return
	end
	const self_ref = self
	self._conn = RunService.PreRender:Connect(function(dt)
		step(self_ref, dt)
	end)
end

function store.stop(self: Store)
	const conn = self._conn
	if conn ~= nil then
		conn:Disconnect()
		self._conn = nil
	end
end

return table.freeze({
	new = store.new,
	RATE = RATE,
	DELAY = DELAY,
})
