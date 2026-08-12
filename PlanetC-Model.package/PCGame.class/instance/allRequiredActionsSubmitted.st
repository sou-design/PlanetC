initialization
allRequiredActionsSubmitted
	| model |
	model := self cormasModel.

	model currentPhase = 2 ifTrue: [
		| activeRangers |
		activeRangers := model rangers select: [ :r | r name isNotNil ].
		^ activeRangers isNotEmpty ].

model currentPhase = 3 ifTrue: [
		| activeHouseholds submitted |
		activeHouseholds := model households select: [ :h | h name isNotEmpty ].
		submitted := model submittedMoves.
		^ activeHouseholds isNotEmpty
			and: [ activeHouseholds allSatisfy: [ :h | submitted includesKey: h ] ] ].

	^ true