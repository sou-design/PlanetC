tests
testRejoinGetsRoleBack
	| ws |
	self startGameWith: #('alice' 'bob').
	ws := self join: 'alice'.
	self assert: (self clientNamed: 'alice') role equals: PCHouseHoldRole.
	self assert: (ws types first: 2) equals: #('registered' 'gameStarted').
	self assert: (((ws messageOfType: 'gameStarted') at: 'payload') at: 'role') equals: 'Household'