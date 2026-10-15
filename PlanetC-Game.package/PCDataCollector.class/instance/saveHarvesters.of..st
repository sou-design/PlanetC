accessing
saveHarvesters: round of: aGame
	| cells rows |
	cells := aGame cormasModel cells.
	rows := OrderedCollection new.
	aGame cormasModel households asArray withIndexDo: [ :family :f |
		family harvesters withIndexDo: [ :harvester :h |
			rows add: (self row: {
				'round_id' -> round.
				'family' -> f.
				'harvester_id' -> h.
				'cell_id' -> (harvester cell ifNotNil: [ :c | cells indexOf: c ]).
				'biomass_qty' -> harvester collectedBiomass }) ] ].
	self write: rows to: 'harvesters'