tests
testNoProtectionInRoundOne
	self send: (Dictionary new at: 'type' put: 'protect'; at: 'cells' put: #( 1 5 7 ); yourself) from: rose.
	self assert: (model cells noneSatisfy: [ :c | c isProtected ])















