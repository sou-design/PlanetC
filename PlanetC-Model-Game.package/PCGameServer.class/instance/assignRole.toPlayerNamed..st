as yet unclassified
assignRole: aRoleName toPlayerNamed: aPlayerName
	| player role |
	game phase = 'lobby' ifFalse: [ ^ 'notInLobby' ].
	player := self clients
		detect: [ :c | c name = aPlayerName and: [ c role ~= PCGameMasterRole ] ]
		ifNone: [ ^ 'unknownPlayer' ].
	aRoleName isEmpty
		ifTrue: [ player role: CMGameNoRole ]
		ifFalse: [
			role := self assignableRoles
				detect: [ :r | r roleName = aRoleName ]
				ifNone: [ ^ 'unknownRole' ].
			role = PCRangerRole
				ifTrue: [ self assignRanger: player ]
				ifFalse: [
					(player role ~= role and: [ (self playersOf: role) size >= (self capacityOf: role) ])
						ifTrue: [ ^ 'roleFull' ].
					player role: role ] ].
	whenClientConnectedBlock value: player.
	^ 'ok'