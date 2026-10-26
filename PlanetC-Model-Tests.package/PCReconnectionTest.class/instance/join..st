splitjoin
join: aName
	| ws |
	ws := CMFakeWebSocket sayingBonjour: aName.
	server handleWebSocket: ws.
	^ ws