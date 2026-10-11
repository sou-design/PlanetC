writing
csvField: aValue
	| text |
	aValue ifNil: [ ^ '' ].
	text := aValue asString.
	^ (text includesAny: ',"' , String crlf)
		ifTrue: [ '"' , (text copyReplaceAll: '"' with: '""') , '"' ]
		ifFalse: [ text ]