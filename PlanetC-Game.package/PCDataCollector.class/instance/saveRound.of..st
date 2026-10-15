accessing
saveRound: round of: aGame
	self
		saveCellStates: round of: aGame;
		saveRoundResults: round of: aGame;
		saveHarvesters: round of: aGame;
		saveFamilyStocks: round of: aGame