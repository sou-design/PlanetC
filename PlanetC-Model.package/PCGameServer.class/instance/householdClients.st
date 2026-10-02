as yet unclassified
householdClients
	^ self clients select: [ :c | c role = PCHouseHoldRole ]