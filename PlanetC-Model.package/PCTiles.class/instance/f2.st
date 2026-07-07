as yet unclassified
f2
	"Generated method"
	<script: 'self f2 inspect'>
	<tile>
	^ self tiles
		at: #f2
		ifAbsentPut: [ CMTile newFrom: self f2Contents ]