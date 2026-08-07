as yet unclassified
relocateStrayHarvestersAwayFrom: aCell 
 
	| farCell |
	farCell := model cells detect: [ :c |
		(c = aCell) not and: [ (aCell neighbourhood includes: c) not ] ].
	model harvesters do: [ :h | h moveTo: farCell ]