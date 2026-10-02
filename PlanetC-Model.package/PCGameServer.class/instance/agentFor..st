as yet unclassified
agentFor: aClient
	| clientsWithSameRole position |
	clientsWithSameRole := self clients select: [ :each | each role = aClient role ].
	position := clientsWithSameRole indexOf: aClient.
	^ (aClient role entitiesIn: game cormasModel) at: position