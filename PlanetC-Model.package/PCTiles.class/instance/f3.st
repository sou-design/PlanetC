as yet unclassified
f3
	"Generated method"
	<script: 'self f3 inspect'>
	<tile>
	^ self tiles
		at: #f3
		ifAbsentPut: [ CMTile newFrom: self f3Contents ]