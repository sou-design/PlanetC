as yet unclassified
assignRanger: aPlayer
	(self clients reject: [ :c | c role = PCGameMasterRole ])
		do: [ :c | c role: PCHouseHoldRole ].
	aPlayer role: PCRangerRole