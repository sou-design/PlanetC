connection open/close
lastMessageOfType: aString
	^ (self messagesOfType: aString) ifEmpty: [ nil ] ifNotEmpty: [ :found | found last ]








