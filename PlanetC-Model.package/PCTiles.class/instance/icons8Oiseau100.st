as yet unclassified
icons8Oiseau100
	"Generated method"
	<script: 'self icons8Oiseau100 inspect'>
	<tile>
	^ self tiles
		at: #icons8Oiseau100
		ifAbsentPut: [ CMTile newFrom: self icons8Oiseau100Contents ]