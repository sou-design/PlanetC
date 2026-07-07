as yet unclassified
f5Icon 
	<tile>
	^ self tiles
		at: #f5Icon
		ifAbsentPut: [ CMTile newFrom: self birdIconContents ]
