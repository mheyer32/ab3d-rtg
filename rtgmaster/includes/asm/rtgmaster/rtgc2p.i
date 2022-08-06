;
;     $VER: rtgsublibs.i 1.007 (15 Jan 1998)

        include "exec/types.i"

 
    STRUCTURE c2p_Info,0
     WORD    CI_ColorDepth           ;CI_256, CI_128, CI_64, CI_EHB, CI_32..
     WORD    CI_CPU                  ;CI_68060, CI_68040, CI_68030....
     WORD    CI_Needs                ;CI_Aikiko, CI_MMU, CI_FPU...
     BYTE    CI_Dirty                ;TRUE/FALSE
     BYTE    CI_Hack                 ;TRUE/FALSE
     ULONG   CI_PixelSize            ;c2p_1x1...
     WORD    CI_WidthAlign           ;Width has to be divisible by <number>
     WORD    CI_HeightAlign          ;Height has to be divisible by <number>
     WORD    CI_Misc                 ;Different stuff...
     ULONG   CI_AmiCompatible        ;Is this compatible to RtgScreenAMI ?
     APTR    CI_Description          ;Pointer to a string
     APTR    CI_Initialization       ;Pointer to Initialization code
     APTR    CI_Expunge              ;Pointer to Expunge code
     APTR    CI_Normal_c2p           ;Pointer to c2p code
     APTR    CI_Normal_c2p_InterL    ;Pointer to Interleaved c2p
     APTR    CI_Scrambled_c2p        ;Pointer to Scrambled c2p
     APTR    CI_Scrambled_c2p_InterL ;Pointer to Scrambled Interleaved c2p
     BYTE    CI_Asynchrone           ;TRUE/FALSE
     LABEL   CI_SIZEOF

; CI_ColorDepth

CI_256 EQU 256
CI_128 EQU 128
CI_64  EQU 64
CI_EHB EQU 32
CI_32  EQU 16
CI_16  EQU 8
CI_8   EQU 4
CI_4   EQU 2
CI_2   EQU 1

; CI_CPU

CI_68060 EQU 1
CI_68040 EQU 2
CI_68030 EQU 4
CI_68020 EQU 8
CI_68060D EQU 16
CI_68040D EQU 32
CI_68030D EQU 64
CI_68020D EQU 128

; CI_Needs

CI_68060N EQU 1
CI_68040N EQU 2
CI_68030N EQU 4
CI_Aikiko EQU 8
CI_MMU    EQU 16
CI_FPU    EQU 32
CI_FAST   EQU 64
CI_2MB    EQU 128

; CI_Misc

CI_Smaller EQU 1
CI_Fixed   EQU 2
CI_Destruct EQU 4

c2p_1x1 EQU 1
c2p_1x2 EQU 2
c2p_2x1 EQU 4
c2p_2x2 EQU 8
c2p_4x2 EQU 16
c2p_2x4 EQU 32
c2p_4x4 EQU 64
c2p_Best EQU 128
c2p_Fastest EQU 256
c2p_Selected EQU 512
c2p_1x1D EQU 1024
c2p_1x2D EQU 2048
c2p_2x1D EQU 4096
c2p_2x2D EQU 8192
c2p_4x2D EQU 16384
c2p_2x4D EQU 32768
c2p_4x4D EQU 65536
c2p_BestD EQU 131072
c2p_FastestD EQU 262144
c2p_SelectedD EQU 524288

c2p_err_Wrong_C2P EQU 1
c2p_err_Wrong_Depth EQU 2
c2p_warn_Wrong_Pixelmode EQU 3
c2p_err_Wrong_Windowsize EQU 4
c2p_warn_divisible EQU 5
c2p_err_hardware EQU 6
c2p_err_memory EQU 7
c2p_err_internal EQU 8
c2p_warn_internal EQU 9
