as yet unclassified
updateVisitState
	self hasHarvesters
		ifTrue: [ visitState := #occupied. ^ self ].
	visitState = #occupied
		ifTrue: [ visitState := #leftOnce. ^ self ].
	visitState = #leftOnce
		ifTrue: [ visitState := #leftTwice. ^ self ].
	visitState = #leftTwice
		ifTrue: [ visitState := #abandoned. ^ self ]