as yet unclassified
move: cellIds for: aHousehold
	self cormasModel recordMove: cellIds for: aHousehold.
	self refreshCormasUI.
	self broadcastHarvesters