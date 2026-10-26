splitjoin
testRejoinInLobbyOnlyRegisters
	| ws |
	self join: 'alice'.
	ws := self join: 'alice'.
	self assert: ws types equals: #('registered')