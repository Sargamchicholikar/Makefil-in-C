# Decide whether the commands will be shwon or not
VERBOSE = TRUE

# Hide or not the calls depending of VERBOSE
ifeq ($(VERBOSE),TRUE)
    HIDE =
else
    HIDE = @
endif

# Compilation flags
CC := gcc
LD := gcc
WINDRES := windres -i
CFLAGS := 
RMFILE := rm -rf
RMDIR := rm -rf
MKDIR := mkdir

# Win OS
ifeq ($(shell uname -o),Msys)
OS_NAME :=
OS_VER :=
OS_DETAILS :=Window
OS_TARGET :=win

# Ubuntu OS
else ifeq ($(shell lsb_release -si),Ubuntu)
OS_NAME :=$(shell lsb_release -si)
OS_VER :=$(shell lsb_release -sr)
OS_DETAILS :=$(OS_NAME)_$(OS_VER)
OS_TARGET :=lnx

# Mac OS
else ifeq ($(shell uname),Darwin)
OS_NAME :=$(shell sw_vers -productName)
OS_VER :=$(shell sw_vers -productVersion)
OS_DETAILS :=$(OS_NAME)_$(OS_VER)
OS_TARGET :=osx

endif

# File paths
PROJ_DIR := $(CURDIR)
TARGET := $(shell basename "$(PROJ_DIR)")
TARGET_DIR := ./Output/$(OS_DETAILS)
SRC_DIR := ./Sources
BUILD_DIR := ./Build
OBJ_DIR := $(BUILD_DIR)/Objs

# Files to be compiled
SRCS := $(wildcard $(SRC_DIR)/*/*.c) $(wildcard $(SRC_DIR)/*.c)
OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
BUILD := $(OBJS:$(OBJ_DIR)/%.o=$(BUILD_DIR)/%)
INCLUDES = $(foreach src, $(SRCS), $(dir $(src)))


ifeq ($(OS_TARGET),win)
    FAVICON_TARGET = favicon_win
	FAVICON_OBJ = $(OBJ_DIR)/favicon.o
else
    FAVICON_TARGET =
	FAVICON_OBJ =
endif

all: preHeader exec postHeader

exec: $(TARGET) clean

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo + CC $<
	$(HIDE)$(MKDIR) -p $(dir $@)
	$(HIDE)$(CC) -m64 -no-pie -s -c $< $(CFLAGS) -o $@
	
$(BUILD_DIR)/%: $(OBJ_DIR)/%.o
	
$(TARGET): $(BUILD) $(FAVICON_TARGET)
	$(HIDE)$(RMDIR) $(TARGET_DIR)
	@echo + LD $@
	$(HIDE)$(MKDIR) -p $(TARGET_DIR)
	$(HIDE)$(LD) -m64 -no-pie -s $(OBJS) $(FAVICON_OBJ) $(CFLAGS) -o $(TARGET_DIR)/$(TARGET)

favicon_win:
	$(HIDE)$(WINDRES) $(SRC_DIR)/favicon.rc -o $(OBJ_DIR)/favicon.o

.PHONY: all

clean:
	$(HIDE)$(RMDIR) $(BUILD_DIR)

preHeader:
	@echo ++++++++++++++++++ $(TARGET) ++++++++++++++++++

postHeader:
	@echo ++++++++++++++++++ $(TARGET) ++++++++++++++++++