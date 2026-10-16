game flow
move: cellIds for: aHousehold
	aHousehold moveHarvestersTo: cellIds.
	householdsWithMove add: aHousehold.
	self refreshCormasUI.
	self broadcastHarvesters