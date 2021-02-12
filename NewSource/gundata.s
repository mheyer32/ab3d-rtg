
; 0=Pistol 1=Big Gun
; ammoleft,ammopershot(b),gunnoise(b),ammoinclip(b)
; VISIBLE/INSTANT (0/FF)
; damage,gotgun(b)
; Delay (w), Lifetime of bullet (w)
; Click or hold down (0,1)
; BulSpd: (w)


PLR1_GunData:
;Pistol
	dc.w         0
	dc.b         8,3
	dc.b         15
	dc.b         -1
	dc.b         4,$ff
	dc.w         5,-1,1,0
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;PlasmaGun
	dc.w         0
	dc.b         8,1
	dc.b         20
	dc.b         0
	dc.b         16,0
	dc.w         10,-1,0,5
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;RocketLauncher
	dc.w         0
	dc.b         8,9
	dc.b         2
	dc.b         0
	dc.b         12,0
	dc.w         30,-1,0,5
	dc.w         0,0,0
	dc.w         1
	ds.w         4

; FlameThrower
	dc.w         90*8
	dc.b         1,22
	dc.b         40
	dc.b         0
	dc.b         8,$0
	dc.w         5,50,1,4
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;Grenade launcher
	dc.w         0
	dc.b         8,9
	dc.b         6
	dc.b         0
	dc.b         8,0
	dc.w         50,100,1,5
	dc.w         60,3
	dc.w         -1000
	dc.w         1
	ds.w         4

; WORMGUN
	dc.w         0
	dc.b         0,0
	dc.b         0
	dc.b         0,0
	dc.w         0,-1,0,5
	dc.w         0,0
	dc.w         0
	dc.w         1
	ds.w         4

; ToughMarineGun
	dc.w         0
	dc.b         0,0
	dc.b         0
	dc.b         0,0
	dc.w         0,-1,0,5
	dc.w         0,0
	dc.w         0
	dc.w         1
	ds.w         4

; Shotgun
	dc.w         0
	dc.b         8,21
	dc.b         15
	dc.b         -1
	dc.b         4,0
	dc.w         50,-1,1,0
	dc.w         0,0,0
	dc.w         7
	ds.w         4

;-----

PLR2_GunData:
	dc.w         0
	dc.b         8,3
	dc.b         15
	dc.b         -1
	dc.b         4,$ff
	dc.w         5,-1,1,0
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;PlasmaGun
	dc.w         0
	dc.b         8,1
	dc.b         20
	dc.b         0
	dc.b         16,0
	dc.w         10,-1,0,5
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;RocketLauncher
	dc.w         0
	dc.b         8,9
	dc.b         2
	dc.b         0
	dc.b         12,0
	dc.w         30,-1,0,5
	dc.w         0,0,0
	dc.w         1
	ds.w         4

; FlameThrower
	dc.w         90*8
	dc.b         1,22
	dc.b         40
	dc.b         0
	dc.b         8,$0
	dc.w         5,50,1,4
	dc.w         0,0,0
	dc.w         1
	ds.w         4

;Grenade launcher
	dc.w         0
	dc.b         8,9
	dc.b         6
	dc.b         0
	dc.b         8,0
	dc.w         50,100,1,5
	dc.w         60,3
	dc.w         -1000
	dc.w         1
	ds.w         4

; WORMGUN
	dc.w         0
	dc.b         0,0
	dc.b         0
	dc.b         0,0
	dc.w         0,-1,0,5
	dc.w         0,0
	dc.w         0
	dc.w         1
	ds.w         4

; ToughMarineGun
	dc.w         0
	dc.b         0,0
	dc.b         0
	dc.b         0,0
	dc.w         0,-1,0,5
	dc.w         0,0
	dc.w         0
	dc.w         1
	ds.w         4

; Shotgun
	dc.w         0
	dc.b         8,21
	dc.b         15
	dc.b         -1
	dc.b         4,0
	dc.w         50,-1,1,0
	dc.w         0,0,0
	dc.w         7
	ds.w         4
