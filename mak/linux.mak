# SPDX-License

# *****************************************
# *** @author: Eduardo Pozos Huerta		***
# *** @file: linux.mak					***
# *** @date: 25/03/2025					***
# *****************************************

# ***********************
# *** Important paths ***
# ***********************

SRC_PATH := src/linux
LIN_PATH := linker/linux
LIB_PATH := build/lib/linux
BIN_PATH := build/bin/linux
OBJ_PATH := build/objects/linux

# ***********************
# *** Important Files ***
# ***********************

LINUX_BIN := $(BIN_PATH)/main
LINUX_LIB := $(LIB_PATH)/libmath.so

LINKER_BIN := $(LIN_PATH)/main/main.ld
LINKER_LIB := $(LIN_PATH)/lib/math.ld

OBJECT_MAIN := $(OBJ_PATH)/main/main.o

# ******************
# *** Find files ***
# ******************

SOURCE := $(shell find $(SRC_PATH) -type f -name '*.asm')
OBJECT := $(patsubst $(SRC_PATH)/%.asm,$(OBJ_PATH)/%.o,$(SOURCE))

OBJECT_LIB := $(filter-out $(OBJECT_MAIN),$(OBJECT))

# *************
# *** Tools ***
# *************

AS := fasm
LD := ld

# *******************
# *** Tools flags ***
# *******************

ASFLAGS := -p 10
LDFLAGS := -I /bin/ld.so -m elf_x86_64 -L /usr/lib/x86_64-linux-gnu

# *************
# *** Rules ***
# *************

all: $(OBJECT) $(LINUX_LIB) $(LINUX_BIN)

run: $(LINUX_BIN)
	@./$<

clean:
	$(RM) $(OBJECT) $(LINUX_LIB) $(LINUX_BIN)

# ********************
# *** .PHONY Rules ***
# ********************

.PHONY: $(RM) \
		$(AS) $(LD) \
		$(ASFLAGS) $(LDFLAGS)

# **********************
# *** Generate files ***
# **********************

$(LINUX_BIN): $(OBJECT_MAIN) $(LINUX_LIB)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) --entry main -o $@ $< -lc

$(LINUX_LIB): $(OBJECT_LIB)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -shared -soname=libmath.so -o $@ $^ -lc -lm

# ***************
# *** Patrons ***
# ***************

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.asm
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< $@