initialization
allRequiredActionsSubmitted
	| households submitted |
	households := server householdClients collect: [ :c | server agentFor: c ].
	submitted := self cormasModel submittedMoves.
	^ households isNotEmpty and: [ households allSatisfy: [ :h | submitted includesKey: h ] ]