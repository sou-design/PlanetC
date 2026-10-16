writing
write: rows to: fileName
	| file |
	rows ifEmpty: [ ^ self ].
	folder ensureCreateDirectory.
	file := folder / (fileName , '.csv').
	file exists ifFalse: [
		file writeStreamDo: [ :s | s << (',' join: rows first keys); lf ] ].
	file writeStreamDo: [ :s |
		s setToEnd.
		rows do: [ :row | s << (',' join: (row values collect: #asString)); lf ] ]