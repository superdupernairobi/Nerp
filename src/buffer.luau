--!strict

const types = require("./types")

const CAPACITY = 16

const buffer = {}
buffer.__index = buffer

export type Buffer = typeof(setmetatable(
	{} :: {
		_samples: { types.Sample },
		_head: number,
		_count: number,
	},
	buffer
))

function buffer.new(): Buffer
	const samples: { types.Sample } = {}
	for i = 1, CAPACITY do
		samples[i] = { t = 0, cf = CFrame.identity }
	end

	const self: Buffer = setmetatable({
		_samples = samples,
		_head = 0,
		_count = 0,
	}, buffer) :: any
	return self
end

function buffer.push(self: Buffer, t: number, cf: CFrame)
	const slot_index = self._head % CAPACITY + 1
	const slot = self._samples[slot_index]
	slot.t = t
	slot.cf = cf
	self._head = slot_index
	if self._count < CAPACITY then
		self._count += 1
	end
end

function buffer.newest(self: Buffer): number
	if self._count == 0 then
		return 0
	end
	return self._samples[self._head].t
end

function buffer.size(self: Buffer): number
	return self._count
end

function buffer.after(self: Buffer, t: number): types.Sample?
	for i = self._count, 1, -1 do
		const index = (self._head - i + CAPACITY) % CAPACITY + 1
		const sample = self._samples[index]
		if sample.t >= t then
			return sample
		end
	end
	return nil
end

function buffer.before(self: Buffer, t: number): types.Sample?
	for i = 1, self._count do
		const index = (self._head - i + CAPACITY) % CAPACITY + 1
		const sample = self._samples[index]
		if sample.t <= t then
			return sample
		end
	end
	return nil
end

return table.freeze({
	new = buffer.new,
	CAPACITY = CAPACITY,
})
