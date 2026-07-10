running
setUp
	super setUp.

	model := PCModel new.
	model nbFamilies: 0.
	model init.
	cell := model cells first.
	cell biomassLevel: 1