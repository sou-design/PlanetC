as yet unclassified
refreshCormasUI
	| spacePresenter |
	spacePresenter := (CMSpacePresenter allInstances
		detect: [ :p | p cormasModel = self cormasModel ]
		ifNone: [ ^ self ]).
	spacePresenter updateDiagram