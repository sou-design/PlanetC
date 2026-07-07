as yet unclassified
newBornIcon 
	<tile>
	^ self tiles
		at: #newBornIcon
		ifAbsentPut: [ CMTile newFrom: self newBornIconData ]
