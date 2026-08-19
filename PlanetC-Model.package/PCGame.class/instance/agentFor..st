initialization
agentFor: aConnectedClient
	| clientsWithSameRole position |
	clientsWithSameRole := server clients select: [ :each | each role = aConnectedClient role ].
	position := clientsWithSameRole indexOf: aConnectedClient.
	^ (aConnectedClient role entitiesIn: self cormasModel) at: position