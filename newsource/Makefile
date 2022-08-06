CC=m68k-amigaos-gcc
ASS=vasmm68k_mot
LINK=vlink

#find the toolchain's directory
PREFIX = $(shell ./getprefix.sh "$(CC)")

CHEESEY ?= 0

#-DCD32VER

AFLAGS = -Fhunk -m68060 -linedebug -align -L listing.txt 
AFLAGS += -I../ \
		  -I$(PREFIX)/m68k-amigaos/ndk-include \
		  -I../newinclude \
		  -I../newstuff \
		  -I../newvectobj \
		  -I../rtgmaster/includes/asm

LFLAGS = -b amigahunk -sd -sc 

all: main

clean:
	rm *.o

%:	%.s Makefile
	$(ASS) $(AFLAGS) -o $@.o $<
	$(LINK) $(LFLAGS) $@.o -o $@

%.o:	%.c Makefile
	$(CC) $(CFLAGS) -c $< -o $@

#############################################################
#
#############################################################
