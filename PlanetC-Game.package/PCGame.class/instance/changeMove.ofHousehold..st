accessing
changeMove: cellIds ofHousehold: index
	| household |
	phase = 'householdsDone' ifFalse: [ ^ 'notReady' ].
	household := self cormasModel households asArray at: index ifAbsent: [ ^ 'notReady' ].
	self move: cellIds for: household.
	self broadcastMoves.
	^ 'ok'