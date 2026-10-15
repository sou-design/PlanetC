as yet unclassified
nameFor: aHousehold
	^ (self householdClients
		detect: [ :c | (self agentFor: c) = aHousehold ]
		ifNone: [ ^ '' ]) name