*****************************
* Bullet object definitions *
*****************************

shotxvel     EQU          18
shotzvel     EQU          22


shotpower    EQU          28
shotstatus   EQU          30
shotsize     EQU          31

shotyvel     EQU          42
accypos      EQU          44
shotanim     EQU          52
shotgrav     EQU          54
shotimpact   EQU          56
shotlife     EQU          58
shotflags    EQU          60
worry        EQU          62
ObjInTop     EQU          63

*****************************
* Nasty definitions *********
*****************************

numlives     EQU          18
damagetaken  EQU          19
maxspd       EQU          20
currspd      EQU          22
targheight   EQU          24

GraphicRoom  EQU          26
CurrCPt      EQU          28

Facing       EQU          30
Lead         EQU          32
ObjTimer     EQU          34
EnemyFlags   EQU          36                        ;(lw)
SecTimer     EQU          40
ImpactX      EQU          42
ImpactZ      EQU          44
ImpactY      EQU          46
objyvel      EQU          48
TurnSpeed    EQU          50
ThirdTimer   EQU          52
FourthTimer  EQU          54

*****************************
* Door Definitions **********
*****************************

DR_Plr_SPC   EQU          0
DR_Plr       EQU          1
DR_Bul       EQU          2
DR_Alien     EQU          3
DR_Timeout   EQU          4
DR_Never     EQU          5

DL_Timeout   EQU          0
DL_Never     EQU          1

*****************************
* Data Offset Defs **********
*****************************

ToZoneFloor  EQU          2
ToZoneRoof   EQU          6
ToUpperFloor EQU          10
ToUpperRoof  EQU          14

ToZoneWater  EQU          18

ToZoneBrightness EQU      22
ToUpperBrightness EQU     24
ToZoneCpt    EQU          26
ToWallList   EQU          28
ToExitList   EQU          32
ToZonePts    EQU          34
ToBack       EQU          36
ToTelZone    EQU          38
ToTelX       EQU          40
ToTelZ       EQU          42
ToFloorNoise EQU          44
ToUpperFloorNoise EQU     46
ToListOfGraph EQU         48

*****************************
* Graphics definitions ******
*****************************

KeyGraph0    	EQU          256*65536*19
KeyGraph1    	EQU          256*65536*19+32
KeyGraph2    	EQU          (256*19+128)*65536
KeyGraph3    	EQU          (256*19+128)*65536+32
Nas1ClosedMouth 	EQU	256*5*65536
MediKit_Graph 	EQU	256*10*65536
BigGun_Graph 	EQU	256*10*65536+32

* Object numbers:
* 0 = alien
* 1 = medikit
* 2 = bullet
* 3 = BigGun
* 4 = Key
* 5 = Marine
* 6 = Robot

maxscrdiv		EQU          8
max3ddiv     	EQU          5
playerheight 	EQU          12*1024
playercrouched 	EQU    	8*1024
scrheight    	EQU          80

; k/j/m
; 4/8
; s/x
; b/n
