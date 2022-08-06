;
;     $VER: rtgCGX.i 1.001 (08 Mar 1997)
;

        IFND    CGXCGX_I
CGXCGX_I        SET     1

        IFND    RTGSUBLIBS_I
        Include "rtgmaster/RtgSublibs.i"
        ENDC

        IFND    EXEC_LIBRARIES_I
        Include "exec/libraries.i"
        ENDC

        IFND    EXEC_TYPES_I
        Include "exec/types.i"
        ENDC

;
; Include files for rtgCGX.library
;
; Only rtgCGX.library specific structures are located in here
; 
 STRUCTURE RtgBaseCGX,0
  STRUCT rbCGX_CGXLibBase,LIB_SIZE
  UWORD rbCGX_Pad1
  ULONG rbCGX_SegList
  APTR  rbCGX_ExecBase
  APTR  rbCGX_UtilityBase
  APTR  rbCGX_DosBase
  APTR  rbCGX_CGXBase
  APTR  rbCGX_GfxBase
  APTR  rbCGX_IntBase
  ULONG rbCGX_Flags
  APTR  rbCGX_ExpansionBase
  APTR  rbCGX_DiskFontBase
  APTR  rbCGX_LinkerDB
  LABEL rbCGX_SIZEOF

 STRUCTURE RtgScreenCGX,0
  STRUCT rsCGX_Header,rs_SIZEOF
  APTR   rsCGX_MyScreen
  ULONG  rsCGX_ActiveMap
  APTR   rsCGX_MapA
  APTR   rsCGX_MapB
  APTR   rsCGX_MapC
  APTR   rsCGX_FrontMap
  ULONG  rsCGX_Bytes
  ULONG  rsCGX_Width
  UWORD  rsCGX_Height
  ULONG  rsCGX_NumBuf
  UWORD  rsCGX_Locks
  APTR   rsCGX_ModeID
  ULONG  rsCGX_RealMapA
  STRUCT rsCGX_Tags,20
  ULONG  rsCGX_OffA
  ULONG  rsCGX_OffB
  ULONG  rsCGX_OffC
  APTR   rsCGX_MyWindow
  STRUCT   rsCGX_PortData,16
  ULONG  rsCGX_BPR
  ULONG  rsCGX_dbi
  ULONG  rsCGX_SafeToWrite
  ULONG  rsCGX_SafeToDisp
  ULONG  rsCGX_Special
  ULONG  rsCGX_SrcMode
  APTR   rsCGX_tempras
  APTR   rsCGX_tempbm
  APTR   rsCGX_wbcolors
  ULONG  rsCGX_colchanged
  ULONG  rsCGX_ccol
  APTR   rsCGX_colarray1
  APTR   rsCGX_colarray2
  LABEL rsCGX_SIZEOF

CALLSYS MACRO
      jsr _LVO\1(a6)
     ENDM

     ENDC
