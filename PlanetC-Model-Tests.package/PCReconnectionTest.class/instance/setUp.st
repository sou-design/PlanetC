running
setUp
	super setUp.
	model := PCModel new.
	model nbFamilies: 2.
	model maxSteps: 5.
	model init.
	game := PCGame new.
	game cormasModel: model.
	server := game server