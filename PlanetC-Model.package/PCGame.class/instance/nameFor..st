initialization
nameFor: anAgent
	"The game master controls no agent, so it is skipped"
	| owner |
	owner := server clients
		detect: [ :c | c role ~= PCGameMasterRole and: [ (self agentFor: c) = anAgent ] ]
		ifNone: [ ^ '' ].
	^ owner name