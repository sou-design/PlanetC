tests
testBirdsAreSentToEveryone
	"Households only draw them after the game master clicks Show birds (web side)"
	| values |
	model installAdultBirds.
	game broadcastBirds.
	values := (alice lastMessageOfType: 'birds') at: 'values'.
	self assert: values size equals: 20.
	self assert: (values inject: 0 into: [ :sum :v | sum + (v at: 'adults') ]) equals: model birds size.
	self assert: (rose hasReceived: 'birds').
	self assert: (gm hasReceived: 'birds')



