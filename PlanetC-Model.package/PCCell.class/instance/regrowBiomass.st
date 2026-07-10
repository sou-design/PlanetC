as yet unclassified
regrowBiomass
	"non-harvest time <= 1, non récoltée -> croissance +1, compteur +1
	 non-harvest time >= 2 -> déclin -1"
	self hasHarvesters ifTrue: [ ^ self ].
	nonHarvestTime <= 1
		ifTrue: [
			self biomassLevel: (biomassLevel + 1 min: 3).
			nonHarvestTime := nonHarvestTime + 1 ]
		ifFalse: [
			self biomassLevel: (biomassLevel - 1 max: 0) ]