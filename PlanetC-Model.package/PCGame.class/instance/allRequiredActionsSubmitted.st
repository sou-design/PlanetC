initialization
allRequiredActionsSubmitted
	| model result |
	model := self cormasModel.
	result := true.
	model currentPhase = 2 ifTrue: [
		| activeRangers |
		activeRangers := model rangers select: [ :r | r name notNil ].
		result := activeRangers isEmpty not
			and: [ (model instVarNamed: 'submittedProtection') isEmpty not ] ].
	model currentPhase = 3 ifTrue: [
		| activeHouseholds |
		activeHouseholds := model households select: [ :h | h name notNil ].
		result := activeHouseholds isEmpty not
			and: [ (model instVarNamed: 'submittedMoves') size >= activeHouseholds size ] ].
	^ result