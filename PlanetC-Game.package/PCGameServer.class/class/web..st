as yet unclassified
web: aFileName
	^ ((IceRepository registry detect: [ :r | r name = 'PlanetC' ]) location / 'web' / aFileName) contents