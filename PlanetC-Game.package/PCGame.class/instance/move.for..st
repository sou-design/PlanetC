broadcast
move: cellIds for: aHousehold
	aHousehold moveHarvestersTo: cellIds.
	householdsWithMove add: aHousehold.
	self broadcastHarvesters.
	server publishState.