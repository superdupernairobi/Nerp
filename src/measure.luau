--!strict

const types = require("./types")

const measure = {}
measure.__index = measure

export type Measure = typeof(setmetatable(
	{} :: {
		_applied: number,
		_held: number,
		_stale: number,
	},
	measure
))

function measure.new(): Measure
	const self: Measure = (
		setmetatable({
			_applied = 0,
			_held = 0,
			_stale = 0,
		}, measure) :: any
	) :: Measure
	return self
end

function measure.applied(self: Measure)
	self._applied += 1
end

function measure.hold(self: Measure)
	self._held += 1
end

function measure.stale(self: Measure)
	self._stale += 1
end

function measure.snapshot(
	self: Measure,
	targets: number,
	renderTime: number,
	newest: number,
	delay: number
): types.Stats
	const stats: types.Stats = {
		targets = targets,
		applied = self._applied,
		held = self._held,
		stale = self._stale,
		renderTime = renderTime,
		newest = newest,
		delay = delay,
	}
	self._applied = 0
	self._held = 0
	self._stale = 0
	return stats
end

return table.freeze({
	new = measure.new,
})
