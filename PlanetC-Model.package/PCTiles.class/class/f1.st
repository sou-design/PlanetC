as yet unclassified
f1

	<script: 'self f1 inspect'>
	^ self tiles
		  at: #f1
		  ifAbsentPut: [ CMTile newFrom: self f1IconData ]