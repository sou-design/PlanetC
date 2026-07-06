as yet unclassified
bird3
	"Generated method"
	<script: 'self bird3 inspect'>
	<tile>
	^ self tiles
		at: #bird3
		ifAbsentPut: [ CMTile newFrom: self bird3Contents ]