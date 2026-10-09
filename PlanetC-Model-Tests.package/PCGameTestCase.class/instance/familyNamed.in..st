running
familyNamed: aString in: aResultsMessage
	^ (aResultsMessage at: 'families') detect: [ :f | (f at: 'name') = aString ]


 



 
