as yet unclassified
bird2
	"Generated method"
	<script: 'self bird2 inspect'>
	<tile>
	^ self tiles
		at: #bird2
		ifAbsentPut: [ CMTile newFrom: self bird2Contents ]