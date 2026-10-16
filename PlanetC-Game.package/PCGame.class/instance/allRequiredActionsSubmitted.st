initialization
allRequiredActionsSubmitted
	| players |
	players := server householdClients select: [ :c | c isConnected ].
	^ players notEmpty and: [
		players allSatisfy: [ :c | householdsWithMove includes: (server agentFor: c) ] ]