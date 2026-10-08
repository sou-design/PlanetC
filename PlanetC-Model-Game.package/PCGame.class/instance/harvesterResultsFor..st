as yet unclassified
harvesterResultsFor: aHousehold
	^ aHousehold harvesters withIndexCollect: [ :harvester :index |
		Dictionary new
			at: 'name' put: 'H' , index printString;
			at: 'gains' put: harvester gains asArray;
			at: 'gain' put: (harvester gains ifEmpty: [ 0 ] ifNotEmpty: [ :g | g last ]);
			at: 'total' put: harvester totalGain;
			yourself ]