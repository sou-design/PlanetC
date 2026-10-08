as yet unclassified
protect: cellIds
	self cormasModel recordProtect: cellIds.
	self refreshCormasUI.
	self broadcastProtection