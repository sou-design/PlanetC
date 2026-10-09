running
setUp
	super setUp.
	model := PCModel new.
	model nbFamilies: 2.
	model init.
	model maxRounds: 3.
	game := PCGame new.
	game cormasModel: model.
	game server instVarNamed: 'server' put: (ZnServer on: 18080).
	gm := self connect: '[GM]' role: PCGameMasterRole.
	alice := self connect: 'alice' role: PCHouseHoldRole.
	bruno := self connect: 'bruno' role: PCHouseHoldRole.
	rose := self connect: 'rose' role: PCRangerRole
 
