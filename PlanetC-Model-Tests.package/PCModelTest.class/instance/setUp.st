running
setUp
	super setUp.

	model := PCModel new.
	model nbFamilies: 1.
	model init.
	cell := model cells first.
	cell biomassLevel: 1