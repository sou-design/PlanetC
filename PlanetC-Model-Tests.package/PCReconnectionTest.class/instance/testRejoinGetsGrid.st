splitjoin
testRejoinGetsGrid
	| state |
	self startGameWith: #('alice' 'bob').
	state := self stateOf: (self join: 'alice').
	#('biomass' 'birds' 'protection' 'harvesters') do: [ :each |
		self assert: (state at: each) size equals: 20 ]