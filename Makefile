#############################################################
# Required variables for each makefile
# Discard this section from all parent makefiles
# Expected variables (with automatic defaults):
#   CSRCS (all "C" files in the dir)
#   SUBDIRS (all subdirs with a Makefile)
#   GEN_LIBS - list of libs to be generated ()
#   GEN_IMAGES - list of object file images to be generated ()
#   GEN_BINS - list of binaries to be generated ()
#   COMPONENTS_xxx - a list of libs/objs in the form
#     subdir/lib to be extracted and rolled up into
#     a generated lib/image xxx.a ()
#

TOP_DIR:=.
sinclude $(TOP_DIR)/tools/tool_chain.def

TARGET = w600

#This matches CONFIG_W800_USE_LIB=n
USE_LIB=0

#EXTRA_CCFLAGS += -u
ifndef PDIR # {
GEN_IMAGES= $(TARGET).out
GEN_BINS = $(TARGET).bin
SUBDIRS = 	\
	$(TOP_DIR)/app	\
	$(TOP_DIR)/platform/boot/$(COMPILE)
#	$(TOP_DIR)/demo
endif # } PDIR

ifndef PDIR # {
ifeq ($(USE_LIB), 0)
SUBDIRS += \
	$(TOP_DIR)/platform/common 		\
	$(TOP_DIR)/platform/drivers		\
	$(TOP_DIR)/platform/sys			\
	$(TOP_DIR)/src/network			\
	$(TOP_DIR)/src/os				\
	$(TOP_DIR)/src/app/dhcpserver	\
	$(TOP_DIR)/src/app/dnsserver	\
	$(TOP_DIR)/src/app/httpclient	\
	$(TOP_DIR)/src/app/matrixssl	\
	$(TOP_DIR)/src/app/ota
endif
endif

COMPONENTS_$(TARGET) =	\
	$(TOP_DIR)/platform/boot/$(COMPILE)/startup.o	\
	$(TOP_DIR)/platform/boot/$(COMPILE)/misc.o	\
	$(TOP_DIR)/platform/boot/$(COMPILE)/retarget.o	\
	$(TOP_DIR)/app/libuser$(LIB_EXT)
#	$(TOP_DIR)/demo/libdemo$(LIB_EXT)

ifeq ($(USE_LIB), 0)
COMPONENTS_$(TARGET) += \
	$(TOP_DIR)/platform/common/libcommon$(LIB_EXT)		\
	$(TOP_DIR)/platform/drivers/libdrivers$(LIB_EXT)		\
	$(TOP_DIR)/platform/sys/libsys$(LIB_EXT)			\
	$(TOP_DIR)/src/network/libnetwork$(LIB_EXT)	\
	$(TOP_DIR)/src/os/libos$(LIB_EXT)	\
	$(TOP_DIR)/src/app/dhcpserver/libdhcpserver$(LIB_EXT)	\
	$(TOP_DIR)/src/app/dnsserver/libdnsserver$(LIB_EXT)	\
	$(TOP_DIR)/src/app/httpclient/libhttpclient$(LIB_EXT)	\
	$(TOP_DIR)/src/app/matrixssl/libmatrixssl$(LIB_EXT)	\
	$(TOP_DIR)/src/app/ota/libota$(LIB_EXT)
endif


LINKLIB = 	\
	$(TOP_DIR)/lib/libwlan$(LIB_EXT)			\
	$(TOP_DIR)/lib/libairkiss_log$(LIB_EXT)


ifeq ($(USE_LIB), 1)
LINKLIB += \
	$(TOP_DIR)/lib/libcommon$(LIB_EXT) 		\
	$(TOP_DIR)/lib/libdrivers$(LIB_EXT)		\
	$(TOP_DIR)/lib/libsys$(LIB_EXT)			\
	$(TOP_DIR)/lib/libnetwork$(LIB_EXT)		\
	$(TOP_DIR)/lib/libos$(LIB_EXT)			\
	$(TOP_DIR)/lib/libapp$(LIB_EXT)
endif

ifeq ($(COMPILE), gcc)
LINKFLAGS_$(TARGET) =  \
	$(LINKLIB)	\
	-T$(LD_FILE)	\
	-Wl,-warn-common 	
else
LINKFLAGS_$(TARGET) = 	\
	--library_type=microlib	\
	$(LINKLIB)	\
	--strict --scatter $(LD_FILE)
endif

#############################################################
# Configuration i.e. compile options etc.
# Target specific stuff (defines etc.) goes in here!
# Generally values applying to a tree are captured in the
#   makefile at its root level - these are then overridden
#   for a subtree within the makefile rooted therein
#

CONFIGURATION_DEFINES =	-DWM_W600 -DPLATFORM_W600

DEFINES +=				\
	$(CONFIGURATION_DEFINES)

DDEFINES +=				\
	$(CONFIGURATION_DEFINES)


#############################################################
# Recursion Magic - Don't touch this!!
#
# Each subtree potentially has an include directory
#   corresponding to the common APIs applicable to modules
#   rooted at that subtree. Accordingly, the INCLUDE PATH
#   of a module can only contain the include directories up
#   its parent path, and not its siblings
#
# Required for each makefile to inherit from the parent
#

INCLUDES := $(INCLUDES) -I$(PDIR)include
INCLUDES += -I ./
#PDIR := ../$(PDIR)
#sinclude $(PDIR)Makefile

sinclude $(TOP_DIR)/tools/rules.mk

.PHONY: FORCE
FORCE:
