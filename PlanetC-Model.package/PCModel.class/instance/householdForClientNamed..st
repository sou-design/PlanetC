as yet unclassified
householdForClientNamed: aName
	| household |
	household := self households detect: [ :h | h name = aName ] ifNone: [ nil ].
	household ifNotNil: [ ^ household ].
	household := self households detect: [ :h | h name isNil ] ifNone: [ ^ nil ].
	household name: aName.
	^ household