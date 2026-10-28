as yet unclassified
refuses: aClient
	^ aClient name = '[GM]'
		and: [ (aClient handshake at: 'gameMaster' ifAbsent: [ false ]) ~= true ]