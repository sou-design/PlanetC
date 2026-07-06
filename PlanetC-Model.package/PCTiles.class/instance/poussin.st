as yet unclassified
poussin
	"Generated method"
	<script: 'self poussin inspect'>
	<tile>
	^ self tiles
		at: #poussin
		ifAbsentPut: [ CMTile newFrom: self poussinContents ]