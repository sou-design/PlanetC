results
recordRoundHarvests
	| harvesters |
	harvesters := self cormasModel harvesters.
	self cormasModel households do: [ :household |
		(self harvestHistoryOf: household) add: ((harvesters select: [ :h | h household == household ])
			inject: 0
			into: [ :sum :h | sum + h collectedBiomass ]) ]