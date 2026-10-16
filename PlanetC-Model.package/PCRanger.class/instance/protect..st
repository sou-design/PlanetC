as yet unclassified
protect: cellIds
	self cormasModel cells do: [ :cell | cell isProtected: false ].
	cellIds do: [ :id | (self cormasModel cells at: id) isProtected: true ]
