--!strict

const types = require("./types")

const CAPACITY = 160

const history = {}
history.__index = history

export type History = typeof(setmetatable(
	{} :: {
		_frames: { { [string]: CFrame } },
		_times: { number },
		_head: number,
		_count: number,
	},
	history
))

function history.new(): History
	const frames: { { [string]: CFrame } } = {}
	for i = 1, CAPACITY do
		frames[i] = {}
	end

	const times: { number } = {}
	for i = 1, CAPACITY do
		times[i] = 0
	end

	const self: History = (
		setmetatable({
			_frames = frames,
			_times = times,
			_head = 0,
			_count = 0,
		}, history) :: any
	) :: History
	return self
end

function history.record(self: History, id: string, t: number, cf: CFrame)
	const head = self._head
	if head > 0 and self._times[head] == t then
		self._frames[head][id] = cf
		return
	end

	const next_index = head % CAPACITY + 1
	const slot = self._frames[next_index]
	table.clear(slot)
	slot[id] = cf
	self._times[next_index] = t
	self._head = next_index
	if self._count < CAPACITY then
		self._count += 1
	end
end

function history.rewind(self: History, t: number): { types.Rewrite }
	const result: { types.Rewrite } = {}
	if self._count == 0 then
		return result
	end

	local picked = -1
	for i = 1, self._count do
		const index = (self._head - i + CAPACITY) % CAPACITY + 1
		const recorded = self._times[index]
		if recorded <= t then
			picked = index
			break
		end
	end

	if picked < 0 then
		picked = (self._head - self._count + CAPACITY) % CAPACITY + 1
	end

	const frame = self._frames[picked]
	for id, cf in frame do
		table.insert(result, { id = id, cf = cf })
	end
	return result
end

function history.span(self: History): (number, number)
	if self._count == 0 then
		return 0, 0
	end
	const oldest = (self._head - self._count + CAPACITY) % CAPACITY + 1
	return self._times[oldest], self._times[self._head]
end

function history.clear(self: History)
	for i = 1, CAPACITY do
		table.clear(self._frames[i])
		self._times[i] = 0
	end
	self._head = 0
	self._count = 0
end

return table.freeze({
	new = history.new,
	CAPACITY = CAPACITY,
})
