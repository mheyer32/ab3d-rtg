
	OPT	O+,W-
	OUTPUT	PROJ:AB3D/NewStuff/12to8tab.bin

val:	SET	0

	REPT	$fff
redt:	SET	val>>3&%11100000
grnt:	SET	val>>2&%00011100
blut:	SET	val>>1&%00000011
	dc.b	redt|grnt|blut
val:	SET	val+1
	ENDR

