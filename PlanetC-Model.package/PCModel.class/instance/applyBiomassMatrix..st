as yet unclassified
applyBiomassMatrix: aMatrix
	| rows cols index |
	rows := 4.
	cols := 5.
	index := 0.
	1 to: rows do: [ :i |
		1 to: cols do: [ :j |
			index := index + 1.
			(self cellAt: i at: j) biomassLevel: (aMatrix at: index) ] ]