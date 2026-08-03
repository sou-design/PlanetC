initialization
assignRolesToConnectedClients
	server clients do: [ :c |
		c role = PCHouseHoldRole
			ifTrue: [ self cormasModel linkClientNamed: c name toEntityIn: self cormasModel households ].
		c role = PCRangerRole
			ifTrue: [ self cormasModel linkClientNamed: c name toEntityIn: self cormasModel rangers ] ]