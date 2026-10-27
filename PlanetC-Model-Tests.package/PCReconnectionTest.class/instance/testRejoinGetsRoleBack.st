as yet unclassified
testRejoinGetsRoleBack
	| ws |
	self startGameWith: #('alice' 'bob').
	ws := self join: 'alice'.
	self assert: (self clientNamed: 'alice') role equals: PCHouseHoldRole.
	self assert: ws types first equals: 'registered'.
	self assert: ((self stateOf: ws) at: 'role') equals: 'Household'