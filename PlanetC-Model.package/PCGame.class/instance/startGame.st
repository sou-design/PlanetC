initialization
startGame
	super startGame.
	self updateAllViews.
	phase := 'ready'