
;--------------------------------------------------------------------------

LoadBGPic:		;Load	bitmap					to BGBitMap planes
	;Entry:	d1=filename

				SAVEREGS

				move.l	#MODE_OLDFILE,d2		;Open file
				DOSCALL	Open
				move.l	d0,-(a7)
				beq.s	.lb_noload

				move.l	(a7),d1					;d1=filehandle
				move.l	BGPicMem,d2				;d2=dest address
				move.l	#10240*8,d3				;d3=length
				CALLA6	Read

				move.l	(a7),d1					;Close filehandle
				CALLA6	Close

.lb_noload:		addq.l	#4,a7
				GETREGS
				rts

;--------------------------------------------------------------------------

LoadPanel:		;Load	the						status panel display gfx

				SAVEREGS

				move.l	#.lb_filenam,d1
				bsr.s	LoadBGPic

				GETREGS
				rts

.lb_filenam:	dc.b	"PROJ:AB3D/NewStuff/Border.raw",0
				EVEN

;--------------------------------------------------------------------------

ReleasePanel:
				rts

;--------------------------------------------------------------------------

load_an_obj:	movem.l	a0/a1/a2,-(a7)

				move.l	(a0),blockname

				move.l	blockname,d1
				move.l	#MODE_OLDFILE,d2
				DOSCALL	Open
				move.l	d0,handle

				lea		fib,a5
				move.l	handle,d1
				move.l	a5,d2
				DOSCALL	ExamineFH
				move.l	$7c(a5),blocklen

				move.l	blocklen,d0
				move.l	#MEMF_PUBLIC,d1
				EXECCALL AllocMem
				move.l	d0,blockstart

				move.l	handle,d1
				move.l	blockstart,d2
				move.l	blocklen,d3
				DOSCALL	Read

				move.l	handle,d1
				DOSCALL	Close

				movem.l	(a7)+,a0/a1/a2

				move.l	blockstart,(a2)+
				move.l	blocklen,(a2)+
				addq	#4,a0
				rts

;---

LoadObjs:		SAVEREGS

				lea		OBJ_ADDRS(pc),a2
				lea		OBJ_NAMES(pc),a0
				lea		Objects,a1

				bsr		load_an_obj
				move.l	blockstart,(a1)
				bsr		load_an_obj
				move.l	blockstart,4(a1)

				bsr		load_an_obj
				move.l	blockstart,16(a1)
				bsr		load_an_obj
				move.l	blockstart,16+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*4)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*4)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*5)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*5)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*6)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*6)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*7)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*7)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*2)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*2)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*9)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*9)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*10)(a1)
				move.l	blockstart,(16*16)(a1)
				move.l	blockstart,(16*17)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*10)+4(a1)
				move.l	blockstart,(16*16)+4(a1)
				move.l	blockstart,(16*17)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*12)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*12)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*13)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*13)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*8)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*8)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*14)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*14)+4(a1)

				bsr		load_an_obj
				move.l	blockstart,(16*15)(a1)
				bsr		load_an_obj
				move.l	blockstart,(16*15)+4(a1)

				GETREGS
				rts

;--------------------------------------------------------------------------

ReleaseObjMem:
				move.l	#OBJ_NAMES,a0
				move.l	#OBJ_ADDRS,a2

.relobjlop:		move.l	(a2)+,blockstart
				move.l	(a2)+,blocklen
				addq	#8,a0
				tst.l	blockstart
				ble.s	.nomoreovj

				movem.l	a0/a2,-(a7)

				move.l	blockstart,d1
				move.l	d1,a1
				move.l	blocklen,d0
				EXECCALL FreeMem

				movem.l	(a7)+,a0/a2
				bra.s	.relobjlop

.nomoreovj:		rts

;--------------------------------------------------------------------------

LOAD_SFX:		move.l	#SFX_NAMES,a0
				move.l	#SampleList,a1
LOADSAMPS		move.l	(a0)+,a2
				move.l	a2,d0
				tst.l	d0
				bgt.s	oktoload
				blt.s	doneload

				addq	#4,a0
				addq	#8,a1
				bra		LOADSAMPS

doneload:		move.l	#-1,(a1)+
				rts
oktoload:		move.l	(a0)+,blocklen
				move.l	a2,blockname
				movem.l	a0/a1,-(a7)
				move.l	#2,d1
				move.l	4.w,a6
				move.l	blocklen,d0
				jsr		-198(a6)
				move.l	d0,blockstart
				move.l	_DOSBase,a6
				move.l	blockname,d1
				move.l	#1005,d2
				jsr		-30(a6)
				move.l	_DOSBase,a6
				move.l	d0,handle
				move.l	d0,d1
				move.l	blockstart,d2
				move.l	blocklen,d3
				jsr		-42(a6)
				move.l	_DOSBase,a6
				move.l	handle,d1
				jsr		-36(a6)
				movem.l	(a7)+,a0/a1
				move.l	blockstart,d0
				move.l	d0,(a1)+
				add.l	blocklen,d0
				move.l	d0,(a1)+
				bra		LOADSAMPS

;--------------------------------------------------------------------------

LoadFloor:		SAVEREGS

				move.l	#MEMF_PUBLIC,d1
				move.l	#65536,d0
				EXECCALL AllocMem
				move.l	d0,FloorTilePtr

				move.l	#.floortilename,d1
				move.l	#MODE_OLDFILE,d2
				DOSCALL	Open
				move.l	d0,handle

				move.l	d0,d1
				move.l	FloorTilePtr,d2
				move.l	#65536,d3
				DOSCALL	Read

				move.l	handle,d1
				DOSCALL	Close

				GETREGS
				rts

.floortilename:
				dc.b	'AB3D1:includes/floortile',0
				EVEN

;---

ReleaseFloorMem:
				SAVEREGS

				lea		FloorTilePtr,a1
				move.l	#65536,d0
				jsr		parole

				GETREGS
				rts

;--------------------------------------------------------------------------

RELEASESAMPMEM:
				move.l	#SampleList,a0
.relmem:		move.l	(a0)+,d1
				bge.s	.okrel
				rts
.okrel:			move.l	(a0)+,d0
				sub.l	d1,d0
				move.l	d1,a1
				move.l	4.w,a6
				move.l	a0,-(a7)
				jsr		-210(a6)
				move.l	(a7)+,a0
				bra		.relmem

;--------------------------------------------------------------------------

unLHA:			INCBIN	Decomp4.raw

;--------------------------------------------------------------------------

SFX_NAMES:		dc.l	ScreamName,4400			;0
				dc.l	ShootName,7200
				dc.l	MunchName,5400
				dc.l	PooGunName,4600
				dc.l	CollectName,3400

				dc.l	DoorNoiseName,8400		;5
				dc.l	BassName,8000
				dc.l	StompName,4000
				dc.l	LowScreamName,8600
				dc.l	BaddieGunName,6200

				dc.l	SwitchNoiseName,1200	;10
				dc.l	ReloadName,4000
				dc.l	NoAmmoName,2200
				dc.l	SplotchName,3000
				dc.l	SplatPopName,5600

				dc.l	BoomName,11600			;15
				dc.l	HissName,7200
				dc.l	Howl1Name,7400
				dc.l	Howl2Name,9200
				dc.l	PantName,5000

				dc.l	WhooshName,4000			;20
				dc.l	ShotGunName,8800
				dc.l	FlameName,9000
				dc.l	MuffledName,1800
				dc.l	ClopName,3400

				dc.l	ClankName,1600			;25
				dc.l	TeleportName,11000
				dc.l	HALFWORMPAINNAME,8400

				dc.l	-1


;--------------------------------------------------------------------------

OBJ_NAMES:		dc.l	wad1n
				dc.l	ptr1n

				dc.l	wad2n
				dc.l	ptr2n

; dc.l wad3n
; dc.l ptr3n

				dc.l	wad4n
				dc.l	ptr4n

				dc.l	wad5n
				dc.l	ptr5n

				dc.l	wad6n
				dc.l	ptr6n

				dc.l	wad7n
				dc.l	ptr7n

				dc.l	wad8n
				dc.l	ptr8n

				dc.l	wad9n
				dc.l	ptr9n

				dc.l	wadan
				dc.l	ptran

				dc.l	wadbn
				dc.l	ptrbn

				dc.l	wadcn
				dc.l	ptrcn

				dc.l	waddn
				dc.l	ptrdn

				dc.l	waden
				dc.l	ptren

				dc.l	wadfn
				dc.l	ptrfn

				dc.l	-1,-1

OBJ_ADDRS:		ds.l	80

;--------------------------------------------------------------------------

ShotGunName:	dc.b	'AB3D2:sounds/shotgun',0
ScreamName:		dc.b	'AB3D2:sounds/scream',0
LowScreamName:	dc.b	'AB3D2:sounds/lowscream',0
BaddieGunName:	dc.b	'AB3D2:sounds/baddiegun',0
BassName:		dc.b	'AB3D2:sounds/splash',0
ShootName:		dc.b	'AB3D2:sounds/fire!',0
MunchName:		dc.b	'AB3D2:sounds/munch',0
PooGunName:		dc.b	'AB3D2:sounds/shoot.dm',0
CollectName:	dc.b	'AB3D2:sounds/collect',0
DoorNoiseName:	dc.b	'AB3D2:sounds/newdoor',0
StompName:		dc.b	'AB3D2:sounds/footstep3',0
SwitchNoiseName: dc.b	'AB3D2:sounds/switch',0
ReloadName:		dc.b	'AB3D2:sounds/switch1.sfx',0
NoAmmoName:		dc.b	'AB3D2:sounds/noammo',0
SplotchName:	dc.b	'AB3D2:sounds/splotch',0
SplatPopName:	dc.b	'AB3D2:sounds/splatpop',0
BoomName:		dc.b	'AB3D2:sounds/boom',0
HissName:		dc.b	'AB3D2:sounds/newhiss',0
Howl1Name:		dc.b	'AB3D2:sounds/howl1',0
Howl2Name:		dc.b	'AB3D2:sounds/howl2',0
PantName:		dc.b	'AB3D2:sounds/pant',0
WhooshName:		dc.b	'AB3D2:sounds/whoosh',0
RoarName:		dc.b	'AB3D2:sounds/bigscream',0
FlameName:		dc.b	'AB3D2:sounds/flame',0
MuffledName:	dc.b	'AB3D2:sounds/MuffledFoot',0
ClopName:		dc.b	'AB3D2:sounds/footclop',0
ClankName:		dc.b	'AB3D2:sounds/footclank',0
TeleportName:	dc.b	'AB3D2:sounds/teleport',0
HALFWORMPAINNAME: dc.b	'AB3D2:sounds/HALFWORMPAIN',0

;--------------------------------------------------------------------------

wad1n:			dc.b	'AB3D1:includes/ALIEN2.wad',0
ptr1n:			dc.b	'AB3D1:includes/ALIEN2.ptr',0
wad2n:			dc.b	'AB3D1:includes/PICKUPS.wad',0
ptr2n:			dc.b	'AB3D1:includes/PICKUPS.ptr',0
;wad3n:       	dc.b         'AB3D1:includes/uglymonster.wad',0
;ptr3n:       	dc.b         'AB3D1:includes/uglymonster.ptr',0
wad4n:			dc.b	'AB3D1:includes/flyingalien.wad',0
ptr4n:			dc.b	'AB3D1:includes/flyingalien.ptr',0
wad5n:			dc.b	'AB3D1:includes/keys.wad',0
ptr5n:			dc.b	'AB3D1:includes/keys.ptr',0
wad6n:			dc.b	'AB3D1:includes/rockets.wad',0
ptr6n:			dc.b	'AB3D1:includes/rockets.ptr',0
wad7n:			dc.b	'AB3D1:includes/barrel.wad',0
ptr7n:			dc.b	'AB3D1:includes/barrel.ptr',0
wad8n:			dc.b	'AB3D1:includes/bigbullet.wad',0
ptr8n:			dc.b	'AB3D1:includes/bigbullet.ptr',0
wad9n:			dc.b	'AB3D1:includes/newgunsinhand.wad',0
ptr9n:			dc.b	'AB3D1:includes/newgunsinhand.ptr',0
wadan:			dc.b	'AB3D1:includes/newmarine.wad',0
ptran:			dc.b	'AB3D1:includes/newmarine.ptr',0
wadbn:			dc.b	'AB3D1:includes/lamps.wad',0
ptrbn:			dc.b	'AB3D1:includes/lamps.ptr',0
wadcn:			dc.b	'AB3D1:includes/worm.wad',0
ptrcn:			dc.b	'AB3D1:includes/worm.ptr',0
waddn:			dc.b	'AB3D1:includes/explosion.wad',0
ptrdn:			dc.b	'AB3D1:includes/explosion.ptr',0
waden:			dc.b	'AB3D1:includes/bigclaws.wad',0
ptren:			dc.b	'AB3D1:includes/bigclaws.ptr',0
wadfn:			dc.b	'AB3D1:includes/tree.wad',0
ptrfn:			dc.b	'AB3D1:includes/tree.ptr',0

				EVEN

;--------------------------------------------------------------------------

blocklen:		dc.l	0
blockname:		dc.l	0
blockstart:		dc.l	0

				CNOP	0,4
FIB:
fib:			dcb.b	fib_SIZEOF				;DOS FileInfoBlock (FIB)

				EVEN
PanelLen:		dc.l	0

;--------------------------------------------------------------------------
