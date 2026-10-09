path commands
moveTo: cellIds
	^ Dictionary new
		at: 'type' put: 'move';
		at: 'harvesterCells' put: cellIds;
		yourself
