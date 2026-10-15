accessing
saveFamilyStocks: round of: aGame
	self
		write: (aGame cormasModel households asArray withIndexCollect: [ :family :f |
			self row: {
				'round_id' -> round.
				'family' -> f.
				'stock' -> family gains sum } ])
		to: 'family_stocks'