as yet unclassified
harvestedBiomass 
	<probeNamed: 'Total harvested biomass' color: 'B90E0A'>
	^ self harvesters sum: [ :harvester | harvester collectedBiomass ]
