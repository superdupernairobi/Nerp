--!strict

--[=[
Interpolation for server driven transforms

The server puts a `CFrame` with a time and the client buffers it and then plays it back a little late, so 20Hz of updates becomees continuous motion at your framerate.

Nerp does not own the network, you just send the batch and then you receive it.

```lua
local Nerp = require(game:GetService("ReplicatedStorage").Nerp)

local store = Nerp.new(20, "SMOOTH") -- OR LOW_LATENCY
store:track(workspace.Crate)
store:start()

remote.OnClientEvent:Connect(function(t, cf)
    store:feed(workspace.Crate:GetFullName(), { { t = t, cf = cf } })
end)
```

@class Nerp
]=]

const store = require("@self/store")
const types = require("@self/types")

export type Store = store.Store

--[=[
Sample spacing the delay is measured in so 20 matches robloxs physics properly

@prop RATE number
@within Nerp
]=]
const RATE = store.RATE

--[=[
Default delay preset. "SMOOTH" is two samples of intervals

@prop DELAY DelayPreset
@within Nerp
]=]
const DELAY = store.DELAY

const Nerp = {}

--[=[
Creates a store

Thee store holds every tracked target, so the render clock and the `PreRender` connection. One store per client is enough for most games.

```lua
local store = Nerp.new(20, "SMOOTH")
```

@param rate number -- Sample spacing in seconds. Default to 20 when nil
@param delay DelayPreset -- `"SMOOTH"` or `"LOW_LATENCY"`. Defaults to `"SMOOTH"`
@return Store
]=]
function Nerp.new(rate: number?, delay: types.DelayPreset?): Store
	return store.new(rate, delay)
end

return table.freeze({
	new = Nerp.new,
	RATE = RATE,
	DELAY = DELAY,
})
