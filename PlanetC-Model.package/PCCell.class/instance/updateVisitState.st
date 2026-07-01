as yet unclassified
updateVisitState 
    self hasHarvesters
        ifTrue:  [ visitState := #occupied.      
						^ self ].
    visitState = #occupied
        ifTrue:  [ visitState := #leftLastRound. 
						^ self ].
    visitState = #leftLastRound
        ifTrue:  [ visitState := #abandoned.     
						^ self ].
