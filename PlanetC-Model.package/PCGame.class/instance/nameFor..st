general
nameFor: anAgent
| owner |
	owner := server clients detect: [ :c | (self agentFor: c) = anAgent ] ifNone: [ ^ '' ].
	^ owner name