as yet unclassified
publishState
	(mutex critical: [ self clients copy ]) do: [ :client | game catchUp: client ]