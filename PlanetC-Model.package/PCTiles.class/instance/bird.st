as yet unclassified
bird
	"Generated method"
	<script: 'self bird inspect'>
	<tile>
	^ self tiles
		at: #bird
		ifAbsentPut: [ CMTile newFrom: self birdContents ]