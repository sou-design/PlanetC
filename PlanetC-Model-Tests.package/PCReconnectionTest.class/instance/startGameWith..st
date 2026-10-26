splitjoin
startGameWith: someNames
	"Les joueurs arrivent, deviennent des familles, la partie démarre"
	someNames do: [ :each | self join: each ].
	server clients do: [ :each | each role: PCHouseHoldRole ].
	server assignAgents.
	self phase: 'ready'