splitjoin
testRejoinGetsGrid
	| ws |
	self startGameWith: #('alice' 'bob').
	ws := self join: 'alice'.
	#('biomass' 'birds' 'protection' 'harvesters') do: [ :each |
		self assert: (ws types includes: each) ]