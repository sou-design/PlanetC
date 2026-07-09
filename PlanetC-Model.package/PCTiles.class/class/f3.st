as yet unclassified
f3
	<script: 'self f3 inspect'>
	<tile>
	^ self tiles
		  at: #f3
		  ifAbsentPut: [ CMTile newFrom: self f3IconData ]