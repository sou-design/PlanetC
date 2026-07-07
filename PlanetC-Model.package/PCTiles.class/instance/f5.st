as yet unclassified
f5
	"Generated method"
	<script: 'self f5 inspect'>
	<tile>
	^ self tiles
		at: #f5
		ifAbsentPut: [ CMTile newFrom: self f5Contents ]