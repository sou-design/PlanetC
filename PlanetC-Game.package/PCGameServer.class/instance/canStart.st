testing
canStart
	| players |
	players := self clients reject: [ :c | c role = PCGameMasterRole ].
	^ (players allSatisfy: #hasRole)
		and: [ (self playersOf: PCHouseHoldRole) notEmpty
		and: [ (self playersOf: PCRangerRole) notEmpty
		and: [ self assignableRoles allSatisfy: [ :r | (self playersOf: r) size <= (self capacityOf: r) ] ] ] ]