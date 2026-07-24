as yet unclassified
regrowBiomass
	"non-harvest time = 0 (harvested last turn) -> croissance +1, compteur +1
	 non-harvest time = 1 (harvested il y a 2 tours) -> stable, compteur +1
	 non-harvest time >= 2 -> déclin -1"
	self hasHarvesters ifTrue: [ ^ self ].
	nonHarvestTime = 0
		ifTrue: [
			self biomassLevel: (biomassLevel + 1 min: 3).
			nonHarvestTime := nonHarvestTime + 1 ]
		ifFalse: [
			nonHarvestTime = 1
				ifTrue: [
					nonHarvestTime := nonHarvestTime + 1 ]
				ifFalse: [
					self biomassLevel: (biomassLevel - 1 max: 0) ] ]