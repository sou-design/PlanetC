as yet unclassified
saveGame
	| now |
	(folder / 'games.csv') exists ifTrue: [ ^ self ].
	now := self now.
	self
		write: { {
			'game_id' -> gameId.
			'organization_name' -> ''.             
			'description' -> 'PlanetC'.            
			'business_type' -> nil.                
			'game_type' -> nil.                    "edit"
			'development_diff' -> nil.             "edit"
			'conservation_diff' -> nil.            "edit"
			'is_valid' -> true.
			'created_by' -> nil.                   "edit"
			'status' -> 'active'.                  "edit"
			'created_at' -> now.
			'updated_at' -> now } asOrderedDictionary }
		to: 'games'