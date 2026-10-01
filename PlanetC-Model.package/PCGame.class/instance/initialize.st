initialization
initialize
	super initialize.
	phase := 'lobby'.
	server := PCGameServer new.
	server whenDataReceivedDo: [ :dict :client |
		| type |
		type := dict at: 'type'.
		type = 'requestGridState' ifTrue: [ self broadcastBiomass ].
		type = 'move' ifTrue: [
			self cormasModel recordMove: (dict at: 'harvesterCells') for: (self agentFor: client).
			self refreshCormasUI.
			self broadcastHarvesters ].
		type = 'protect' ifTrue: [
			self cormasModel recordProtect: (dict at: 'cells').
			self refreshCormasUI.
			self broadcastProtection ].
		self handleGameMasterRequest: dict from: client ]