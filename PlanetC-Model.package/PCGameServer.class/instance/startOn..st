accessing
startOn: aPortNumber
	| wsDelegate dispatcher |
	server ifNotNil: [ self error: 'Already running!' ].

	dispatcher := ZnDispatcherDelegate new.
	wsDelegate := ZnWebSocketDelegate map: '/' to: [ :ws | self handleWebSocket: ws ].

	dispatcher map: '/ws' to: [ :request :response | wsDelegate handleRequest: request ].
	dispatcher map: '/' to: [ :request :response | response entity: (ZnEntity html: self class loginPageHtml) ].
	dispatcher map: '/style.css' to: [ :request :response |
		response entity: (ZnEntity with: self class stylesheet type: (ZnMimeType fromString: 'text/css')) ].
	dispatcher map: '/app.js' to: [ :request :response |
		response entity: (ZnEntity with: self class clientScript type: (ZnMimeType fromString: 'application/javascript')) ].
	dispatcher map: '/icons/bird.png' to: [ :request :response |
		response entity: (ZnEntity with: PCTiles birdIconData base64Decoded type: (ZnMimeType fromString: 'image/png')) ].
	dispatcher map: '/icons/poussin.png' to: [ :request :response |
		response entity: (ZnEntity with: PCTiles poussinIconData base64Decoded type: (ZnMimeType fromString: 'image/png')) ].

	server := ZnServer startOn: aPortNumber.
	self log: ('Started a server at localhost:', aPortNumber asString).
	server delegate: dispatcher