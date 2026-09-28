accessing
startOn: aPortNumber
	| wsDelegate dispatcher |
	server ifNotNil: [ self error: 'Already running!' ].

	dispatcher := ZnDispatcherDelegate new.
	wsDelegate := ZnWebSocketDelegate map: '/' to: [ :ws | self handleWebSocket: ws ].

	dispatcher map: '/ws' to: [ :request :response | wsDelegate handleRequest: request ].
	"Pages and scripts are sent with no-store, so browsers always load the latest version after a change.
	Each block must answer the response: the dispatcher sends the block value back to the browser."
	dispatcher map: '/' to: [ :request :response |
		response entity: (ZnEntity html: self class loginPageHtml).
		response headers at: 'Cache-Control' put: 'no-store'.
		response ].
	dispatcher map: '/style.css' to: [ :request :response |
		response entity: (ZnEntity with: self class stylesheet type: (ZnMimeType fromString: 'text/css')) ].
	dispatcher map: '/app.js' to: [ :request :response |
		response entity: (ZnEntity with: self class clientScript type: (ZnMimeType fromString: 'application/javascript')).
		response headers at: 'Cache-Control' put: 'no-store'.
		response ].
	dispatcher map: '/gm' to: [ :request :response |
		response entity: (ZnEntity html: self class gmPageHtml).
		response headers at: 'Cache-Control' put: 'no-store'.
		response ].
	dispatcher map: '/gm.js' to: [ :request :response |
		response entity: (ZnEntity with: self class gmScript type: (ZnMimeType fromString: 'application/javascript')).
		response headers at: 'Cache-Control' put: 'no-store'.
		response ].
	dispatcher map: '/qrcode.js' to: [ :request :response |
		response entity: (ZnEntity with: self class qrCodeLibrary type: (ZnMimeType fromString: 'application/javascript')) ].
	dispatcher map: '/icons/bird.png' to: [ :request :response |
		response entity: (ZnEntity with: PCTiles birdIconData base64Decoded type: (ZnMimeType fromString: 'image/png')) ].
	dispatcher map: '/icons/poussin.png' to: [ :request :response |
		response entity: (ZnEntity with: PCTiles poussinIconData base64Decoded type: (ZnMimeType fromString: 'image/png')) ].

	server := ZnServer startOn: aPortNumber.
	self log: ('Started a server at localhost:', aPortNumber asString).
	server delegate: dispatcher