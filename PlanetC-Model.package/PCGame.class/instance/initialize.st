initialization
initialize
	super initialize.
	server := PCGameServer new.
	server whenDataReceivedDo: [ :data :client |
		| type |
		type := data at: 'type' ifAbsent: [ nil ].
		type = 'requestGridState' ifTrue: [ self broadcastBiomass ].
		type = 'move' ifTrue: [
			self cormasModel
				recordMove: (data at: 'harvesterCells' ifAbsent: [ nil ])
				forClientNamed: client name ].
		type = 'protect' ifTrue: [
			self cormasModel
				recordProtect: (data at: 'cells' ifAbsent: [ nil ])
				forClientNamed: client name ] ]