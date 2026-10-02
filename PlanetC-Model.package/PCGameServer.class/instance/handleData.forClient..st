as yet unclassified
handleData: aDictionary forClient: aClient
	| type |
	type := aDictionary at: 'type' ifAbsent: [ ^ self ].
	type = 'ping' ifTrue: [ ^ aClient sendPongMessage ].
	(type beginsWith: 'gm') ifTrue: [ ^ self handleGameMasterRequest: aDictionary from: aClient ].
	type = 'move' ifTrue: [ ^ game move: (aDictionary at: 'harvesterCells') for: (self agentFor: aClient) ].
	type = 'protect' ifTrue: [ ^ game protect: (aDictionary at: 'cells') ]