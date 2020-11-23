ARCH = armv7-a
MCPU = cortex-a8

TARGET = rvpi

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
#LD = arm-none-eabi-ld
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./uos.ld
MAP_FILE = build/uos.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

VPATH = boot \
	hal/$(TARGET) \
	lib \
	kernel

C_SRCS = $(notdir $(wildcard boot/*.c))
C_SRCS += $(notdir $(wildcard hal/$(TARGET)/*.c))
C_SRCS += $(notdir $(wildcard lib/*.c))
C_SRCS += $(notdir $(wildcard kernel/*.c))
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))

INC_DIRS = -I include 	\
	   -I hal	\
	   -I hal/$(TARGET) \
	   -I lib \
	   -I kernel

CFLAGS = -c -g -std=c11 -mthumb-interwork

LDFAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

uos = build/uos.axf
uos_bin = build/uos.bin

.PHONY: all clean run dubug gdb

all: $(uos)

clean :
	@rm -rf build

run: $(uos)
	qemu-system-arm -M realview-pb-a8 -kernel $(uos) -nographic

debug: $(uos)
	qemu-system-arm -M realview-pb-a8 -kernel $(uos) -S -gdb tcp::1235,ipv4 -nographic

gdb:
	arm-none-eabi-gdb

$(uos): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(uos) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFAGS) 
	$(OC) -O binary $(uos) $(uos_bin)

build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<

build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC)  -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<
