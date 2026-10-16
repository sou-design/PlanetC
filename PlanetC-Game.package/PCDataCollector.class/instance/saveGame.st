as yet unclassified
saveGame
	| now |
	now := DateAndTime now .
	self
		write: { {
			'game_id' -> gameId.
			'organization_name' -> ''.             
			'description' -> 'PlanetC'.            
			'business_type' -> ''.                
			'game_type' -> ''.                    
			'development_diff' -> ''.          
			'conservation_diff' -> ''.           
			'is_valid' -> ''.
			'created_by' -> ''.                  
			'status' -> 'active'.                 
			'created_at' -> DateAndTime now .
			'updated_at' -> DateAndTime now  } asOrderedDictionary }
		to: 'games'