initialization
assignAgents
	agents := Dictionary new.
	self assignableRoles do: [ :role |
		| entities |
		entities := role entitiesIn: game cormasModel.
		(self playersOf: role) withIndexDo: [ :client :index |
			agents at: client name put: (entities at: index) ] ]