initialization
resetHarvest 
	children do: [ :harvester | harvester resetHarvest ]
