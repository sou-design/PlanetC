splitjoin
householdOf: aName
	^ server agentFor: (self clientNamed: aName)