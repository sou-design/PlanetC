accessing
now
	| now |
	now := DateAndTime now.
	^ now asDate yyyymmdd , ' ' , now asTime print24