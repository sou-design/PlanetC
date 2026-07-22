as yet unclassified
rangerForClientNamed: aName
	| ranger |
	ranger := self rangers detect: [ :r | r name = aName ] ifNone: [ nil ].
	ranger ifNotNil: [ ^ ranger ].
	ranger := self rangers detect: [ :r | r name isNil ] ifNone: [ ^ nil ].
	ranger name: aName.
	^ ranger