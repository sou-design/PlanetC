running
waitUntil: aBlock
	"Messages of a turn are sent from a background process: wait up to 3 seconds"
	| deadline |
	deadline := Time millisecondClockValue + 3000.
	[ aBlock value or: [ Time millisecondClockValue > deadline ] ]
		whileFalse: [ (Delay forMilliseconds: 20) wait ].
	self assert: aBlock value







 



 
