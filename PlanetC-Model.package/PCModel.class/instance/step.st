stepping
step
	<control>
	currentStep > maxSteps ifTrue: [ ^ self ].
	self updateEnvironment.
	self applyActions