as yet unclassified
f1
	"Generated method"
	<script: 'self f1 inspect'>
	<tile>
	^ self tiles
		at: #f1
		ifAbsentPut: [ CMTile newFrom: self f1Contents ]