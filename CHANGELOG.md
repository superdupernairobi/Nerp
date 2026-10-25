# Changelog

## 0.1.0

Initial release.

- `Nerp.new(rate, delay)` creates a store
- `store:track(inst, opts)` registers a part or a welded model
- `store:feed(id, samples)` pushes timestamped CF's
- `store:start()` / `store:stop()` bind the `Prerender` connection
- `store:stats()` returns a per frame count
- `track(instance, { apply = false })` computes without writing to the inst