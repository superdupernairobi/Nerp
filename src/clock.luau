--!strict

const types = require("./types")

const DELAY_MULTIPLE: { [types.DelayPreset]: number } = {
	SMOOTH = 2,
	LOW_LATENCY = 1.5,
}

const SYNC_RATE = 4

const RESET_AFTER = 0.5

const clock = {}
clock.__index = clock

export type Clock = typeof(setmetatable(
	{} :: {
		_renderTime: number,
		_delay: number,
		_started: boolean,
	},
	clock
))

const function delay_seconds(rate: number, preset: types.DelayPreset): number
	return DELAY_MULTIPLE[preset] / rate
end

function clock.new(rate: number, preset: types.DelayPreset): Clock
	const delay = delay_seconds(rate, preset)
	const self: Clock = setmetatable({
		_renderTime = 0,
		_delay = delay,
		_started = false,
	}, clock)
	return self
end

function clock.now(self: Clock): number
	return self._renderTime
end

function clock.jump(self: Clock, t: number)
	self._renderTime = t
	self._started = true
end

function clock.delay(self: Clock): number
	return self._delay
end

function clock.advance(self: Clock, dt: number, newest: number): (number, boolean)
	const target: number = newest - self._delay

	if not self._started then
		self._renderTime = target
		self._started = true
		return self._renderTime, false
	end

	self._renderTime += dt
	const k: number = 1 - math.exp(-dt * SYNC_RATE)
	self._renderTime += (target - self._renderTime) * k

	if self._renderTime > newest then
		self._renderTime = newest
	end

	const stale: boolean = self._renderTime < target - self._delay
	if stale then
		self._renderTime = target - self._delay
	end

	return self._renderTime, stale
end

return table.freeze({
	new = clock.new,
	RESET_AFTER = RESET_AFTER,
})
