splitjoin
clientNamed: aName
	^ server clients detect: [ :each | each name = aName ]