game flow
catchUp: aClient
	(phase = 'lobby'
		or: [ aClient hasRole not
		or: [ aClient role = PCGameMasterRole
		or: [ aClient isConnected not ] ] ]) ifTrue: [ ^ self ].
	[ aClient sendMessage: (self stateFor: aClient) ]
		on: Error
		do: [ :e | Transcript showCr: 'Could not send the state to ', aClient name printString, ': ', e messageText ]