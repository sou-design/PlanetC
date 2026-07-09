as yet unclassified
f4

	<script: 'self f4 inspect'>
	<tile>
	^ self tiles
		  at: #f4
		  ifAbsentPut: [ CMTile newFrom: self f4IconData ]