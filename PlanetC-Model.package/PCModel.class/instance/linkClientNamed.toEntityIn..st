as yet unclassified
linkClientNamed: aName toEntityIn: aCollection

	^ aCollection
		detect: [ :e | e name = aName ]
		ifNone: [
			(aCollection detect: [ :e | e name = '' ])
				name: aName;
				yourself ]