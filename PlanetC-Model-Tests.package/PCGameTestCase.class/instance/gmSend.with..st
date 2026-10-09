running
gmSend: aType with: aDictionary
	gm clearMessages.
	aDictionary at: 'type' put: aType.
	self send: aDictionary from: gm.
	^ gm lastMessageOfType: aType









 



 
