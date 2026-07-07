as yet unclassified
birdIcon 
	<tile>
	^ self tiles
		at: #birdIcon
		ifAbsentPut: [ CMTile newFrom: self birdIconData ]
