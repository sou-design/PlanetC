initialization
allRequiredActionsSubmitted
	| model |
	model := self cormasModel.

	model currentPhase = 2 ifTrue: [
		| activeRangers |
		activeRangers := model rangers select: [ :r | r name isNotNil ].
		^ activeRangers isEmpty not and: [ model submittedProtection isNotEmpty ] ].

	model currentPhase = 3 ifTrue: [
		| activeHouseholds submitted |
		activeHouseholds := model households select: [ :h | h name isNotNil ].
		submitted := model submittedMoves.
		^ activeHouseholds isEmpty not
			and: [ activeHouseholds allSatisfy: [ :h | submitted includesKey: h ] ] ].

	^ true