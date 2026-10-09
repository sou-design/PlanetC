connection open/close
sendGameStartedMessage
	self sendMessage: (Dictionary new
		at: 'type' put: 'gameStarted';
		at: 'payload' put: (Dictionary new at: 'role' put: role roleName; yourself);
		yourself)















