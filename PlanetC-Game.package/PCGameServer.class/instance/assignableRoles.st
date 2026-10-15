as yet unclassified
assignableRoles
	^ game availableRoles reject: [ :role | role = PCGameMasterRole ]