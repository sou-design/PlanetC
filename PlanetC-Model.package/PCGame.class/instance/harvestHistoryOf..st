results
harvestHistoryOf: aHousehold
	^ harvestHistory
		at: aHousehold
		ifAbsentPut: [ OrderedCollection new ]