as yet unclassified
poussin

	<script: 'self poussin inspect'>
	<tile>
	^ self tiles
		  at: #poussin
		  ifAbsentPut: [ CMTile newFrom: self poussinIconData ]