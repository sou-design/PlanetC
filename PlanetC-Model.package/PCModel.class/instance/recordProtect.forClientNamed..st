as yet unclassified
recordProtect: cellsArray forClientNamed: aName
	| ranger |
	cellsArray ifNil: [ ^ self ].
	ranger := self rangerForClientNamed: aName.
	ranger ifNil: [ ^ self ].
	submittedProtection := cellsArray