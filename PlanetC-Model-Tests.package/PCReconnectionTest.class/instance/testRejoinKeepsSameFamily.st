tests
testRejoinKeepsSameFamily
	| before |
	self startGameWith: #('alice' 'bob').
	before := self householdOf: 'alice'.
	self join: 'alice'.
	self assert: (self householdOf: 'alice') identicalTo: before.
	self deny: (self householdOf: 'bob') == before