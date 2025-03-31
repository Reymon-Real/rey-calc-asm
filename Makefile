# SPDX-License

# ****************************
# *** Set Operating System ***
# ****************************

TARGET ?= Linux

# *****************
# *** Compiling ***
# *****************

ifeq ($(TARGET),Windows_NT)

	include mak/windows_nt.mak

else ifeq ($(TARGET),Linux)

	include mak/linux.mak

else ifeq ($(TARGET),Darwin)

	include mak/darwin.mak

endif


# *******************
# *** Error Rules ***
# *******************

error:
	echo "Don't support"