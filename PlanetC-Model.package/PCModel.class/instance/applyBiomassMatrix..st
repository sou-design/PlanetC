as yet unclassified
applyBiomassMatrix: aMatrix
    | rows cols cell index |
    rows := 4.
    cols := 5.
    1 to: rows do: [ :i |
        1 to: cols do: [ :j |
            index := ((i - 1) * cols) + j.
            cell := self cellAt: i at: j.
            cell biomassLevel: (aMatrix at: index) ]]