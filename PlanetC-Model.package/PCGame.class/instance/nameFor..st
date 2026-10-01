initialization
nameFor: anAgent
	| owner |
	owner := server clients
		detect: [ :c | c role ~= PCGameMasterRole and: [ (self agentFor: c) = anAgent ] ]
		ifNone: [ ^ '' ].
	^ owner name