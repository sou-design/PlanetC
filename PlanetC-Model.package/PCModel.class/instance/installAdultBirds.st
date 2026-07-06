initialization
installAdultBirds
	self birds do: [ :b | self removeEntity: b ].
	(self cells select: [ :cell | cell hasEnoughBiomass ]) do: [ :cell |
		| bird |
		bird := self newEntity: PCBird.
		bird state: #adult.
		bird moveTo: cell ]
