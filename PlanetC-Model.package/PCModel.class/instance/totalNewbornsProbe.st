as yet unclassified
totalNewbornsProbe
	<probeNamed: 'New borns' color: '2A9D8F'>
	^ self cells inject: 0 into: [ :sum :cell | sum + cell nbNewBorns ]
