connection open/close
sendMessage: aDictionaryOrString
	messages add: (aDictionaryOrString isString
		ifTrue: [ STONJSON fromString: aDictionaryOrString ]
		ifFalse: [ aDictionaryOrString ])















