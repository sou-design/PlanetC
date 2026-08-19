as yet unclassified
recordMove: cellsArray for: aHousehold
	submittedMoves at: aHousehold put: cellsArray.
	aHousehold moveHarvestersTo: cellsArray