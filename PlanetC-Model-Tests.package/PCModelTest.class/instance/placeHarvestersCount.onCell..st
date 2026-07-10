as yet unclassified
placeHarvestersCount: aNumber onCell: aCell
	| harvesters |
	harvesters := OrderedCollection new.
	aNumber timesRepeat: [
		| h |
		h := model newEntity: PCHarvester.
		h moveTo: aCell.
		harvesters add: h ].
	^ harvesters