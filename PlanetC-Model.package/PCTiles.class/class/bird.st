as yet unclassified
bird
	<script: 'self bird inspect'>
	<tile>
	^self tiles
		  at: #bird
		  ifAbsentPut: [ CMTile newFrom: self birdIconData ]