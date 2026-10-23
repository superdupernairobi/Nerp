--!strict

export type Sample = {
	t: number,
	cf: CFrame,
}

export type FeedMeta = {
	rate: number?,
}

export type SampleBatch = {
	samples: { Sample },
	meta: FeedMeta?,
}

export type DelayPreset = "SMOOTH" | "LOW_LATENCY"

export type ClockConfig = {
	rate: number,
	delay: DelayPreset,
}

export type Clock = {
	now: () -> number,
	jump: (t: number) -> (),
	advance: (dt: number, newest: number) -> (number, boolean),
	delay: () -> number,
}

export type TrackOptions = {
	apply: boolean?,
}

export type RigKind = "part" | "model"

export type Target = {
	id: string,
	instace: BasePart | Model,
	kind: RigKind,
	apply: boolean,
	buffer: Buffer,
}

export type Buffer = {
	push: (t: number, cf: CFrame) -> (),
	newest: () -> number,
	size: () -> number,
	after: (t: number) -> Sample?,
	before: (t: number) -> Sample?,
}

export type Output = {
	id: string,
	cf: CFrame,
}

export type Stats = {
	targets: number,
	applied: number,
	held: number,
	renderTime: number,
	newest: number,
	delay: number,
}

export type Nerp = {
	Track: (instance: BasePart | Model, options: TrackOptions?) -> Target,
	Untrack: (target: Target) -> (),
	Samples: () -> { Output },
	Start: () -> (),
	Stop: () -> (),
	Stats: () -> Stats,
}

return {}
