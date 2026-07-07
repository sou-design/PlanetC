as yet unclassified
f2Icon 
	<tile>
	^ self tiles
		at: #f2Icon
		ifAbsentPut: [ CMTile newFrom: self birdIconContents ]
