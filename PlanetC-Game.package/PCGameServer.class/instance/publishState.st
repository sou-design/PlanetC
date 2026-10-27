as yet unclassified
publishState
	mutex critical: [ self clients do: [ :client | game catchUp: client ] ]