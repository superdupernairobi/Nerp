--!strict

--[=[
Interpolation for server driven transforms

The server puts a `CFrame` with a time and the client buffers it and then plays it back a little late, so 20Hz of updates becomes continuous motion at your framerate.

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
const history = require("@self/history")

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

@function Nerp.new

@param rate number -- Sample spacing in seconds. Default to 20 when nil
@param delay DelayPreset -- `"SMOOTH"` or `"LOW_LATENCY"`. Defaults to `"SMOOTH"`
@param options StoreOptions -- Optional. `{extrapolate = 0.1}` lets the clock run past the newest sample instead of holding. Clamped to 0.1
@return Store
]=]
function Nerp.new(rate: number?, delay: types.DelayPreset?, options: types.StoreOptions?): Store
	return store.new(rate, delay, options)
end

--[=[
Creates a server-side transform history

Records what the server sent so a lag compensation user can rewind without trusting a number that the client reports. Call `record` each tick on the server, `rewind` when resolving a shot.

```lua
local h = Nerp.history()
h:record(player.Name, now, root.CFrame)
```

@function Nerp.history
@return History
]=]
return table.freeze({
	new = Nerp.new,
	RATE = RATE,
	DELAY = DELAY,
	history = history.new,
})
