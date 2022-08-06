SOCK_STREAM EQU 1
SOCK_DGRAM EQU 2

 STRUCTURE RTG_Socket,0
  ULONG rsock_s
  ULONG rsock_num
  APTR  rsock_list
  ; Following : A lot of stuff
  ; that you do not need...
  ; DO NOT TOUCH IT !!!
  ; I WARNED YOU !!! FINGER OFF
  ; THE REST OF THE RTG_SOCKET STRUCTURE !!!
  ; THE ONLY THINGS YOU ARE ALLOWED TO TOUCH
  ; IN ASM IS rsock_s, rsock_num and rsock_list !!!
  STRUCT rsock_Garbage,48
  LABEL rsock_SIZEOF

 STRUCTURE RTG_Buff,0
  STRUCT rbuff_sock,12288
  ; 12 1024 Byte strings !!!
  STRUCT rbuff_num,48
  ; Each num is a 32 Bit value !!!
  ULONG rbuff_in_size
  ULONG rbuff_out_size
  LABEL rbuff_SIZEOF



