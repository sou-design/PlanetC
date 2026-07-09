as yet unclassified
f5

	<script: 'self f5 inspect'>
	<tile>
	^ self tiles
		  at: #f5
		  ifAbsentPut: [ CMTile newFrom: self f5IconData ]