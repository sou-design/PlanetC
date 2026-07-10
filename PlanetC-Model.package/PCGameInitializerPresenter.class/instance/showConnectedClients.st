as yet unclassified
showConnectedClients
	| rangerCount familyCount total |
	super showConnectedClients.
	rangerCount := game server clients count: [ :c | c role = PCRangerRole ].
	familyCount := game server clients count: [ :c | c role = PCHouseHoldRole ].
	total := game server clients size.
	(rangerCount = 1 and: [ familyCount >= 4 and: [ total >= 5 and: [ total <= 21 ] ] ])
		ifFalse: [ startGameButton disable ]