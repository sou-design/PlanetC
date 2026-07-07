as yet unclassified
f3Icon 
	<tile>
	^ self tiles
		at: #f3Icon
		ifAbsentPut: [ CMTile newFrom: self birdIconContents ]
