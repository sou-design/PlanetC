initialization
allRequiredActionsSubmitted
	| households |
	households := server householdClients collect: [ :c | server agentFor: c ].
	^ households isNotEmpty and: [ households allSatisfy: [ :h | householdsWithMove includes: h ] ]