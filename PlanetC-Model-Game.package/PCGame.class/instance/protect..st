game flow
protect: cellIds
	self cormasModel recordProtect: cellIds.
	self refreshCormasUI.
	self broadcastProtection