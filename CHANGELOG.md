# Changelog

## 0.2.0

- `Nerp.new(rate, delay, options)` takes an options table
- `extrapolate` lets the clock run past the newest sample instead of holding, clamped to 0.1 seconds
- Interpolation blends the samples before the pair, so one late packet bends the path instead of being reproduced exactly
- `Nerp.history()` records server transforms and rewinds to a time, for lag comp
- `stats().newest` reports the best newest sample across all targets

## 0.1.0

Initial release.

- `Nerp.new(rate, delay)` creates a store
- `store:track(inst, opts)` registers a part or a welded model
- `store:feed(id, samples)` pushes timestamped CF's
- `store:start()` / `store:stop()` bind the `Prerender` connection
- `store:stats()` returns a per frame count
- `track(instance, { apply = false })` computes without writing to the inst