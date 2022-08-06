
titlecop:		dc.w	intreq,$8010

				dc.w	$10c,$0088

				dc.w	$1fc,$f

				dc.w	$106,$c40

				dc.w	spr0ptl
tsp0l:			dc.w	0
				dc.w	spr0pth
tsp0h:			dc.w	0
				dc.w	spr1ptl
tsp1l:			dc.w	0
				dc.w	spr1pth
tsp1h:			dc.w	0
				dc.w	spr2ptl
tsp2l:			dc.w	0
				dc.w	spr2pth
tsp2h:			dc.w	0
				dc.w	spr3ptl
tsp3l:			dc.w	0
				dc.w	spr3pth
tsp3h:			dc.w	0
				dc.w	spr4ptl
tsp4l:			dc.w	0
				dc.w	spr4pth
tsp4h:			dc.w	0
				dc.w	spr5ptl
tsp5l:			dc.w	0
				dc.w	spr5pth
tsp5h:			dc.w	0
				dc.w	spr6ptl
tsp6l:			dc.w	0
				dc.w	spr6pth
tsp6h:			dc.w	0
				dc.w	spr7ptl
tsp7l:			dc.w	0
				dc.w	spr7pth
tsp7h:			dc.w	0

				dc.w	$106,$8c40
OPTSCRNCOP:
val				SET		$180
				REPT	8
				dc.w	val,$fff
val				SET		val+2
				dc.w	val,$fff
val				SET		val+2
				dc.w	val,$500
val				SET		val+2
				dc.w	val,$fff
val				SET		val+2

				ENDR
				dc.w	$106,$ac40
val				SET		$180
				REPT	32
				dc.w	val,$fff
val				SET		val+2
				ENDR

				dc.w	$108,0
				dc.w	$10a,0

				dc.w	$106,$8c40

OPTCOP:
val				SET		$2c
				REPT	32
				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$448
				dc.w	color07,$448
				dc.w	color11,$448
				dc.w	color13+4,$448

				dc.w	color02,$200
				dc.w	color06,$200
				dc.w	color10,$200
				dc.w	color13+2,$200

				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$77a
				dc.w	color07,$77a
				dc.w	color11,$77a
				dc.w	color13+4,$77a

				dc.w	color02,$400
				dc.w	color06,$400
				dc.w	color10,$400
				dc.w	color13+2,$400


				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$aac
				dc.w	color07,$aac
				dc.w	color11,$aac
				dc.w	color13+4,$aac

				dc.w	color02,$600
				dc.w	color06,$600
				dc.w	color10,$600
				dc.w	color13+2,$600


				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$ccf
				dc.w	color07,$ccf
				dc.w	color11,$ccf
				dc.w	color13+4,$ccf

				dc.w	color02,$800
				dc.w	color06,$800
				dc.w	color10,$800
				dc.w	color13+2,$800

				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$ccf
				dc.w	color07,$ccf
				dc.w	color11,$ccf
				dc.w	color13+4,$ccf

				dc.w	color02,$800
				dc.w	color06,$800
				dc.w	color10,$800
				dc.w	color13+2,$800


				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$aac
				dc.w	color07,$aac
				dc.w	color11,$aac
				dc.w	color13+4,$aac

				dc.w	color02,$600
				dc.w	color06,$600
				dc.w	color10,$600
				dc.w	color13+2,$600


				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color02,$400
				dc.w	color06,$400
				dc.w	color10,$400
				dc.w	color13+2,$400


				dc.w	color03,$77a
				dc.w	color07,$77a
				dc.w	color11,$77a
				dc.w	color13+4,$77a

				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				dc.b	val,$01,$ff,$00
				dc.w	color01,$f00
				dc.w	color05,$f00
				dc.w	color09,$f00
				dc.w	color13,$f00

				dc.w	color03,$448
				dc.w	color07,$448
				dc.w	color11,$448
				dc.w	color13+4,$448

				dc.w	color02,$200
				dc.w	color06,$200
				dc.w	color10,$200
				dc.w	color13+2,$200

				dc.b	val,$df,$ff,$fe
val				SET		val+1
val				SET		val&255

				ENDR

				dc.w	$ffff,$fffe
