initialization
allRequiredActionsSubmitted
	| model activeHouseholds submitted |
	model := self cormasModel.
	activeHouseholds := model households select: [ :h | h name isNotEmpty ].
	submitted := model submittedMoves.
	^ activeHouseholds isNotEmpty
		and: [ activeHouseholds allSatisfy: [ :h | submitted includesKey: h ] ]