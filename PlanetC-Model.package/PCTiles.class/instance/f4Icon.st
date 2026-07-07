as yet unclassified
f4Icon 
	<tile>
	^ self tiles
		at: #f4Icon
		ifAbsentPut: [ CMTile newFrom: self birdIconContents ]
