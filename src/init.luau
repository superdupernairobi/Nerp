--!strict

const store = require("@self/store")

export type Store = store.Store

return table.freeze({
	new = store.new,
	RATE = store.RATE,
	DELAY = store.DELAY,
})
