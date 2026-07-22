initialization
assignRolesToConnectedClients
	server clients do: [ :c |
		c role = PCHouseHoldRole ifTrue: [ self cormasModel householdForClientNamed: c name ].
		c role = PCRangerRole ifTrue: [ self cormasModel rangerForClientNamed: c name ] ]