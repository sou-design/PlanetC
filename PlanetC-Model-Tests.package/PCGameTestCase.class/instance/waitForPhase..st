running
waitForPhase: aString
	"Turns run in background processes: wait up to 3 seconds for the phase"
	| deadline |
	deadline := Time millisecondClockValue + 3000.
	[ game phase = aString or: [ Time millisecondClockValue > deadline ] ]
		whileFalse: [ (Delay forMilliseconds: 20) wait ].
	self assert: game phase equals: aString






 



 
