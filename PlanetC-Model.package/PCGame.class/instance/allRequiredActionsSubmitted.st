initialization
allRequiredActionsSubmitted
	| model activeHouseholds submitted |
	model := self cormasModel.
	activeHouseholds := (server clients select: [ :c | c role = PCHouseHoldRole ])
		collect: [ :c | self agentFor: c ].
	submitted := model submittedMoves.
	^ activeHouseholds isNotEmpty
		and: [ activeHouseholds allSatisfy: [ :h | submitted includesKey: h ] ]