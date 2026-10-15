accessing
saveCellStates: round of: aGame
	self
		write: (aGame cormasModel cells withIndexCollect: [ :cell :id |
			self row: {
				'round_id' -> round.
				'cell_id' -> id.
				'is_protected' -> cell isProtected.
				'biomass' -> cell biomassLevel.
				'newborns' -> cell nbNewBorns } ])
		to: 'cell_states'