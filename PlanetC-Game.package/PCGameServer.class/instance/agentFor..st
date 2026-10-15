as yet unclassified
agentFor: aClient
	| position |
	position := (self playersOf: aClient role) indexOf: aClient.
	^ (aClient role entitiesIn: game cormasModel) at: position