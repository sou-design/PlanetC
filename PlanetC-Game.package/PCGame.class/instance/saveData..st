as yet unclassified
saveData: aBlock
	recorder ifNil: [ ^ self ].
	aBlock
		on: Error
		do: [ :e | Transcript showCr: 'PlanetC data not saved: ' , e messageText ]