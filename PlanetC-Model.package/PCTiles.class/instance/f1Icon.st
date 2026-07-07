as yet unclassified
f1Icon 
	<tile>
	^ self tiles
		at: #f1Icon
		ifAbsentPut: [ CMTile newFrom: self birdIconContents ]
