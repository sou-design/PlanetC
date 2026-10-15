broadcast
broadcastMoves
	| model message |
	model := self cormasModel.
	message := Dictionary new
		at: 'type' put: 'gmMoves';
		at: 'households' put: (model households asArray withIndexCollect: [ :household :index |
			Dictionary new
				at: 'index' put: index;
				at: 'name' put: (server nameFor: household);
				at: 'cells' put: (household children asArray collect: [ :harvester |
					harvester cell ifNotNil: [ :cell | model cells indexOf: cell ] ]);
				yourself ]);
		yourself.
	(server clients select: [ :c | c role = PCGameMasterRole ])
		do: [ :c | c sendMessage: message ]