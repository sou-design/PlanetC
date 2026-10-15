accessing
saveRoundResults: round of: aGame
	| cells |
	cells := aGame cormasModel cells.
	self
		write: { self row: {
			'round_id' -> round.
			'total_harvest' -> aGame cormasModel harvestedBiomass.
			'final_biomass' -> (cells inject: 0 into: [ :sum :cell | sum + (self biomassAfterHarvest: cell) ]).
			'total_newborns' -> (cells inject: 0 into: [ :sum :cell | sum + cell nbNewBorns ]).
			'end_time_at' -> self now } }
		to: 'round_results'