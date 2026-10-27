as yet unclassified
othersIn: aState
	^ (aState at: 'harvesters') inject: 0 into: [ :sum :each | sum + (each at: 'others') ]