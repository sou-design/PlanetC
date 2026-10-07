initialization
recordGain
	children do: [ :harvester | harvester recordGain ].
	gains add: (children inject: 0 into: [ :sum :harvester | sum + harvester collectedBiomass ])