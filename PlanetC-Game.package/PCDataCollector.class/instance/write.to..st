writing
write: rows to: fileName
	| file |
	rows ifEmpty: [ ^ self ].
	folder ensureCreateDirectory.
	file := folder / (fileName , '.csv').
	file exists ifFalse: [
		file writeStreamDo: [ :stream | stream << (self csvLine: rows first keys); lf ] ].
	file writeStreamDo: [ :stream |
		stream setToEnd.
		rows do: [ :row | stream << (self csvLine: row values); lf ] ]