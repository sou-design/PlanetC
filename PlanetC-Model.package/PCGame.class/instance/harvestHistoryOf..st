results
harvestHistoryOf: aHousehold
	^ (harvestHistory ifNil: [ harvestHistory := IdentityDictionary new ])
		at: aHousehold
		ifAbsentPut: [ OrderedCollection new ]