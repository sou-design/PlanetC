accessing
saveRoundResults: round of: aGame
	| model |
	model := aGame cormasModel.
	self
		write: { self row: {
			'round_id' -> round.
			'total_harvest' -> model harvestedBiomass.
			'final_biomass' -> model biomassAfterHarvest.
			'total_newborns' -> model totalNewborns.
			'end_time_at' -> DateAndTime now  } }
		to: 'round_results'