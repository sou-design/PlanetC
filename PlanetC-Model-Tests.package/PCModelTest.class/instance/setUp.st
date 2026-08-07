running
setUp
	super setUp.

	model := PCModel new.
	model nbFamilies: 1.
	model init.
	cell := model cells first.
	cell biomassLevel: 1.
	harvester := model newEntity: PCHarvester.
	harvester2 := model newEntity: PCHarvester.
	harvester3 := model newEntity: PCHarvester