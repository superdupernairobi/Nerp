---
sidebar_position: 1
---

# Getting started

Nerp smooths the gap between how fast the server sends and how fast you draw. The server stamps a CF with a timee, and the client buffers it and plays it back slightly late, so 20Hz of updates becomes a continuous motion aat whatever your FR is.

It does not do any networking, you send the batch and you recieve the batch, keeps it simple.

## Install

```toml
[dependencies]
Nerp = "superdupernairobi/nerp@0.1.0"
```
Studio users: grab `Nerp.rbxm` from the latest release and put it in `ReplicatedStorage`.

## Example
```lua
local Nerp = require(game:GetService("ReplicatedStorage").Nerp)

local store = Nerp.new(20, "SMOOTH") -- OR LOW_LATENCY
store:track(workspace.with_nerp)
store:start()

remote.OnClientEvent:Connect(function(t, cf)
    store:feed(workspace.with_nerp:GetFullName(), { { t = t, cf = cf } })
end)
```

# The delay is a multiple and not a time
`"SMOOTH"` is two samples of intervals, `"LOW_LATENCY"` is one and a half, so, at 20Hz that is 100ms and 75ms.
Basically, two intervals leaves one whole sample of slack, so a single late packet still has a pair to interpolate between. At one interval the clock sits on the newest sample and any jitter pushes it past the end, which is where extrapolation starts. `LOW_LATENCY` is the one that can extrapolate, so it is for close combat and not for vehicles.

## What to feed it
One sample is `{ t: number, cf: CFrame }`, `t` is a server held timestamp, it uses `Workspace:GetServerTimeNow()` which is the obvious source. Feed thee ID you tracked, which is `inst:GetFullName()`

## Stats
`store:stats()` returns counts for the last frame, which is: `targets`, `applied`, `held`, `stale`, plus `renderTime`, `newest` and `delay`. `applied` and `held` should sum to `targets`, when `held` climbs, the buffer has nothing to interpolate between at the render time, which usually means the feed key does not match the tracked id.