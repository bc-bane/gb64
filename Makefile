#!smake -k
# --------------------------------------------------------------------
#        Copyright (C) 1997,1998 Nintendo. (Originated by SGI)
#
#        $RCSfile: Makefile,v $
#        $Revision: 1.9 $
#        $Date: 1999/04/02 10:10:22 $
# --------------------------------------------------------------------
#
# Makefile for game template
#
#

include $(ROOT)/usr/include/make/PRdefs

FINAL = YES
ifeq ($(FINAL), YES)
OPTIMIZER       = -O2 -std=gnu90 -Werror
LCDEFS          = -D_FINALROM -DNDEBUG -DF3DEX_GBI_2
ASFLAGS         = -mabi=32
N64LIB          = -lultra_rom
else
OPTIMIZER       = -g -std=gnu90 -Werror
LCDEFS          = -DDEBUG -DF3DEX_GBI_2
ASFLAGS         = -mabi=32
N64LIB          = -lultra_d
endif

APP =		bin/gb.out

TARGETS =	bin/gb.n64

HFILES =	boot.h game.h controller.h font.h font_ext.h \
		letters_img.h static.h \
		src/test/cpu_test.h    \
		src/cpu.h              \
		src/memory_map.h

CODEFILES   =	boot.c game.c controller.c font.c dram_stack.c \
       src/test/cpu_test.c                   \
       src/test/cpu_tests_0.c                \
       src/test/cpu_tests_1.c                \
       src/test/cpu_tests_2.c                \
       src/test/cpu_tests_3.c                \
       src/test/cpu_tests_4_7.c              \
       src/test/cpu_tests_8_9.c              \
       src/test/cpu_tests_A_B.c              \
       src/test/cpu_tests_C.c                \
       src/test/cpu_tests_D.c                \
       src/test/cpu_tests_E.c                \
       src/test/cpu_tests_F.c                \
       src/test/cpu_tests_prefix_cb.c        \
       src/test/register_test.c              \
       src/test/interrupt_test.c             \
       src/cpu.c                             \
       src/rom.c                             \
       src/memory_map.c                      \
       src/gameboy.c                         \
       src/graphics.c                        \
       memory.c                              \
       src/test/graphics_test.c              \
       src/test/test.c                       \
       src/debug_out.c 

S_FILES = asm/cpu.s

CODEOBJECTS =	$(CODEFILES:.c=.o) $(S_FILES:.s=.o)

DATAFILES   =	gfxinit.c \
		rsp_cfb.c \
		cfb.c \
		zbuffer.c

DATAOBJECTS =	$(DATAFILES:.c=.o)

CODESEGMENT =	codesegment.o

OBJECTS =	$(CODESEGMENT) $(DATAOBJECTS)

LCDEFS +=	$(HW_FLAGS)
LCINCS =	-I. -I/usr/include/n64/PR -I/usr/include/n64
LCOPTS =	-G 0
LDFLAGS =	$(MKDEPOPT)  -L/usr/lib/n64 $(N64LIB) -lkmc

LDIRT  =	$(APP) $(TARGETS)

default:	$(TARGETS)

asm/cpu.o: asm/memory.inc asm/registers.inc asm/_branch.s \
       asm/_cpu_inst_prefix.s asm/_math.s asm/_stopping_point.s \
       asm/_memory.s \
       asm/_cpu_inst_0.s asm/_cpu_inst_1.s asm/_cpu_inst_2.s asm/_cpu_inst_3.s \
       asm/_cpu_inst_4.s asm/_cpu_inst_5.s asm/_cpu_inst_6.s asm/_cpu_inst_7.s \
       asm/_cpu_inst_8.s asm/_cpu_inst_9.s asm/_cpu_inst_A.s asm/_cpu_inst_B.s \
       asm/_cpu_inst_C.s asm/_cpu_inst_D.s asm/_cpu_inst_E.s asm/_cpu_inst_F.s

include $(COMMONRULES)

$(CODESEGMENT):	$(CODEOBJECTS)
		$(LD) -o $(CODESEGMENT) -r $(CODEOBJECTS) $(LDFLAGS)

ifeq ($(FINAL), YES)
$(TARGETS) $(APP):      spec $(OBJECTS)
	$(MAKEROM) -s 9 -r $(TARGETS) -e $(APP) spec
	makemask $(TARGETS)
else
$(TARGETS) $(APP):      spec $(OBJECTS)
	$(MAKEROM) -r $(TARGETS) -e $(APP) spec
endif

font.o:		./letters_img.h

cleanall: clean
	rm -f $(CODEOBJECTS) $(OBJECTS)

rsp/%.o: rsp/%.s
	$(RSPASM) $< -o $@

