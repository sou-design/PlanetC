as yet unclassified
localNetworkAddresses
	"IPv4 addresses of this laptop, read from the network configuration:
	ipconfig on Windows, ip (Linux) or ifconfig (macOS) otherwise.
	Loopback (127.x) and self-assigned (169.254.x) addresses are skipped.
	Home and office network addresses (192.168.x, 10.x, 172.x) come first."
	| file command output addresses rank |
	file := FileLocator temp / 'cormas-ipconfig.txt'.
	command := OSPlatform current isWindows
		ifTrue: [ 'ipconfig > "' , file fullName , '"' ]
		ifFalse: [ '(ip -4 -o addr || /sbin/ifconfig) > "' , file fullName , '" 2>/dev/null' ].
	output := [
		LibC runCommand: command.
		file exists
			ifTrue: [ file binaryReadStreamDo: [ :stream | stream upToEnd asString ] ]
			ifFalse: [ '' ] ]
		on: Error
		do: [ :e | self log: 'Could not read the network configuration: ' , e printString. '' ].
	file ensureDelete.

	"Windows lines look like 'IPv4 Address. . . : 192.168.1.20',
	Linux and macOS lines contain 'inet 192.168.1.20'"
	addresses := OrderedCollection new.
	output lines do: [ :line |
		| marker found |
		marker := #( 'IPv4' 'inet ' ) detect: [ :each | line includesSubstring: each ] ifNone: [ nil ].
		marker ifNotNil: [
			found := (line copyFrom: (line findString: marker) + marker size to: line size)
				allRegexMatches: '\d+\.\d+\.\d+\.\d+'.
			found ifNotEmpty: [ addresses addIfNotPresent: found first ] ] ].
	addresses := addresses reject: [ :each | (each beginsWith: '127.') or: [ each beginsWith: '169.254.' ] ].

	rank := [ :ip |
		(ip beginsWith: '192.168.') ifTrue: [ 1 ] ifFalse: [
		(ip beginsWith: '10.') ifTrue: [ 2 ] ifFalse: [
		(ip beginsWith: '172.') ifTrue: [ 3 ] ifFalse: [ 4 ] ] ] ].
	^ (addresses asSortedCollection: [ :a :b | (rank value: a) <= (rank value: b) ]) asArray