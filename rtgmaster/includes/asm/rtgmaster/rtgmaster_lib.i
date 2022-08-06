**
**      $VER: rtgmaster_lib.i 1.0 (15.1.98)
**

_LVOOpenRtgScreen       =     -30
_LVOCloseRtgScreen      =     -36
_LVOSwitchScreens       =     -42
_LVOLoadRGBRtg  =     -48
_LVOLockRtgScreen       =     -54
_LVOUnlockRtgScreen     =     -60
_LVOGetBufAdr   =     -66
_LVOGetRtgScreenData    =     -72
_LVORtgAllocSRList  =     -78
_LVOFreeRtgSRList  =     -84
;_LVORtgScreenAtFront    =     -90
_LVORtgScreenModeReq    =     -96
_LVOFreeRtgScreenModeReq        =     -102
_LVOWriteRtgPixel       =     -108
_LVOWriteRtgPixelRGB    =     -114
_LVOFillRtgRect =     -120
_LVOFillRtgRectRGB      =     -126
_LVOWriteRtgPixelArray  =     -132
_LVOWriteRtgPixelRGBArray       =     -138
_LVOCopyRtgPixelArray   =     -144
_LVOCopyRtgBlit      =     -150
_LVODrawRtgLine =     -156
_LVODrawRtgLineRGB      =     -162
_LVOWaitRtgSwitch       =     -168
_LVOWaitRtgBlit =     -174
_LVORtgWaitTOF = -180
_LVORtgBlit = -186
_LVORtgBltClear =     -192
_LVOCallRtgC2P = -198
_LVORtgBestSR = -204
_LVORtgCheckVSync = -210
_LVORtgInitBobSystem = -216
_LVORtgText = -270
_LVORtgSetFont = -276
_LVORtgClearPointer = -282
_LVORtgSetPointer = -288
_LVORtgSetTextMode = -294
_LVORtgOpenFont = -300
_LVORtgCloseFont = -306
_LVOSetTextModeRGB = -312
_LVORtgInitRDCMP = -318
_LVORtgWaitRDCMP = -324
_LVORtgGetMsg = -330
_LVORtgReplyMsg = -336
_LVOCloseRtgBobSystem = -228
_LVORtgBobrefreshBuffer = -234
_LVORtgBobDrawSprite = -240
_LVOPPCOpenRtgScreen       =     -342
_LVOPPCCloseRtgScreen      =     -348
_LVOPPCSwitchScreens       =     -354
_LVOPPCLoadRGBRtg  =     -360
_LVOPPCLockRtgScreen       =     -366
_LVOPPCUnlockRtgScreen     =     -372
_LVOPPCGetBufAdr   =     -378
_LVOPPCGetRtgScreenData    =     -384
_LVOPPCRtgAllocSRList  =     -390
_LVOPPCFreeRtgSRList  =     -396
;_LVOPPCRtgScreenAtFront    =     -402
_LVOPPCRtgScreenModeReq    =     -408
_LVOPPCFreeRtgScreenModeReq        =     -414
_LVOPPCWriteRtgPixel       =     -420
_LVOPPCWriteRtgPixelRGB    =     -426
_LVOPPCFillRtgRect =     -432
_LVOPPCFillRtgRectRGB      =     -438
_LVOPPCWriteRtgPixelArray  =     -444
_LVOPPCWriteRtgPixelRGBArray       =     -450
_LVOPPCCopyRtgPixelArray   =     -456
_LVOPPCCopyRtgBlit      =     -462
_LVOPPCDrawRtgLine =     -468
_LVOPPCDrawRtgLineRGB      =     -474
_LVOPPCWaitRtgSwitch       =     -480
_LVOPPCWaitRtgBlit =     -486
_LVOPPCRtgWaitTOF = -492
_LVOPPCRtgBlit = -498
_LVOPPCRtgBltClear =     -504
_LVOPPCCallRtgC2P = -510
_LVOPPCRtgBestSR = -516
_LVOPPCRtgCheckVSync = -522
_LVOPPCRtgInitBobSystem = -528
_LVOPPCRtgText = -582
_LVOPPCRtgSetFont = -588
_LVOPPCRtgClearPointer = -594
_LVOPPCRtgSetPointer = -600
_LVOPPCRtgSetTextMode = -606
_LVOPPCRtgOpenFont = -612
_LVOPPCRtgCloseFont = -618
_LVOPPCSetTextModeRGB = -624
_LVOPPCRtgInitRDCMP = -630
_LVOPPCRtgWaitRDCMP = -636
_LVOPPCRtgGetMsg = -642
_LVOPPCRtgReplyMsg = -648
_LVOPPCCloseRtgBobSystem = -540
_LVOPPCRtgBobrefreshBuffer = -546
_LVOPPCRtgBobDrawSprite = -552
_LVORtgScreenAtFront = -654
_LVOPPCRtgScreenAtFront = -660
_LVORtgConvert = -666
_LVOPPCRtgConvert = -672

                IFND    _POWERMODE

CALLRTGMASTER   MACRO
                move.l  _RTGMasterBase,a6
                jsr     _LVO\1(a6)
                ENDM

                ELSEIF

                IFND    POWERPC_PPCMACROS_I
                INCLUDE powerpc/ppcmacros.i
                ENDC

CALLRTGMASTER   MACRO
                lw      r3,_RTGMasterBase
                lwz     r0,_LVO\1+2(r3)
                mtlr    r0
                blrl
                ENDM

                ENDC


