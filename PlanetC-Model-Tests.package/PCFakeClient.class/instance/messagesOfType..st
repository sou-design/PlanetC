connection open/close
messagesOfType: aString
	^ messages select: [ :m | (m at: 'type' ifAbsent: [ nil ]) = aString ]










