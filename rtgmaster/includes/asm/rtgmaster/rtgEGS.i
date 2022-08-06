;
;     $VER: rtgEGS.i 1.003 (08 Mar 1997)
;

        IFND    RTGEGS_I
RTGEGS_I        SET     1

        IFND    RTGSUBLIBS_I
        Include "include:Rtgmaster/RtgSublibs.i"
        ENDC

        IFND    EXEC_LIBRARIES_I
        Include "exec/libraries.i"
        ENDC

        IFND    EXEC_TYPES_I
        Include "exec/types.i"
        ENDC

;
; Include files for rtgEGS.library
;
; Only rtgEGS.library specific structures are located in here
; 
 STRUCTURE RtgBaseEGS,0
  STRUCT rbEGS_EGSLibBase,LIB_SIZE
  UWORD rbEGS_Pad1
  ULONG rbEGS_SegList
  APTR  rbEGS_ExecBase
  APTR  rbEGS_UtilityBase
  APTR  rbEGS_DosBase
  APTR  rbEGS_EgsBase
  APTR  rbEGS_EgsBlitBase
  APTR  rbEGS_GFXBase
  ULONG rbEGS_Flags
  APTR  rbEGS_EgsGfxBase
  APTR  rbEGS_ExpansionBase
  LABEL rbEGS_SIZEOF

 STRUCTURE RtgScreenEGS,0
  STRUCT rsEGS_Header,rs_SIZEOF
  APTR   rsEGS_MyScreen
  ULONG  rsEGS_ActiveMap
  APTR   rsEGS_MapA
  APTR   rsEGS_MapB
  APTR   rsEGS_MapC
  APTR   rsEGS_FrontMap
  ULONG  rsEGS_Bytes
  ULONG  rsEGS_Width
  ULONG  rsEGS_Type
  ULONG  rsEGS_NumBuf
  UWORD  rsEGS_Locks
  APTR   rsEGS_RastPort1
  APTR   rsEGS_RastPort2
  APTR   rsEGS_RastPort3
  STRUCT rsEGS_Pointer,28
  STRUCT rsEGS_PointerA,256
  STRUCT rsEGS_PointerB,1024
  STRUCT rsEGS_PointerC,28
  STRUCT   rsEGS_PortData,16
  LABEL rsEGS_SIZEOF

CALLSYS MACRO
      jsr _LVO\1(a6)
     ENDM

     ENDC
