running
connect: aName role: aRole
	| client |
	client := PCFakeClient named: aName.
	client role: aRole.
	(game server instVarNamed: 'clients') at: aName put: client.
	^ client
 



 
