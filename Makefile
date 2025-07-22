# SPDX-License

# ****************************
# *** Set Operating System ***
# ****************************

TARGET ?= linux

# ***********************
# *** Important Paths ***
# ***********************

SRC_PATH := src/$(TARGET)
INC_PATH := include/$(TARGET)
LIN_PATH := linker/$(TARGET)
LIB_PATH := build/$(TARGET)/lib
OBJ_PATH := build/$(TARGET)/obj
BIN_PATH := build/$(TARGET)/bin

# *****************
# *** Compiling ***
# *****************

ifeq ($(TARGET), windows)

	include mak/windows_nt.mak

else ifeq ($(TARGET), linux)

	include mak/linux.mak

else ifeq ($(TARGET), darwin)

	include mak/darwin.mak

endif