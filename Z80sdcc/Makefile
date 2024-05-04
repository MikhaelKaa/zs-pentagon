# We only allow compilation on linux!
ifneq ($(shell uname), Linux)
$(error OS must be Linux!)
endif

TARGET = main
CODE_LOCATION = 0x0000
DATA_LOCATION = 0x3000

# Check if all required tools are on the system.
REQUIRED = sdcc sdar sdasz80
K := $(foreach exec,$(REQUIRED),\
    $(if $(shell which $(exec)),,$(error "$(exec) not found. Please install or add to path.")))

# Global settings: folders.
ROOT 		=	$(realpath .)
BUILD_DIR	=	$(ROOT)/build
SRC_DIR		=	$(ROOT)/src

# Globa settings: tools.
CC			=	sdcc
AS			=	sdasz80
CFLAGS		=	--std-c11 -mz80 --debug --nostdinc --no-std-crt0 --nostdinc --nostdlib
ASFLAGS		=	-xlos -g

.PHONY:	all
all:
	# Create build dir.
	mkdir -p $(BUILD_DIR)

	# Compile crt0.s
	# rm $(BUILD_DIR)/crt0.s
	cp $(SRC_DIR)/crt0.s $(BUILD_DIR)/crt0.s
	$(AS) $(ASFLAGS) $(BUILD_DIR)/crt0.s

	# Compile main.c
	$(CC) -o $(BUILD_DIR)/$(TARGET).rel -c $(CFLAGS) $(SRC_DIR)/main.c
	# Compile print.c
	$(CC) -o $(BUILD_DIR)/print.rel -c $(CFLAGS) $(SRC_DIR)/print.c
	# Compile tl16c550.c
	$(CC) -o $(BUILD_DIR)/tl16c550.rel -c $(CFLAGS) $(SRC_DIR)/tl16c550.c
	
	# Link both
	$(CC) -o $(BUILD_DIR)/main.ihx \
		-mz80 -Wl -y --code-loc $(CODE_LOCATION) --data-loc $(DATA_LOCATION) \
		--std-c11 -mz80 --debug --no-std-crt0 --nostdinc --nostdlib \
		-Llib -llibsdcc-z80  \
		$(BUILD_DIR)/crt0.rel \
		$(BUILD_DIR)/tl16c550.rel \
		$(BUILD_DIR)/print.rel \
		$(BUILD_DIR)/main.rel
	
	# Finally, convert ihx to binary
	sdobjcopy -I ihex -O binary $(BUILD_DIR)/main.ihx $(BUILD_DIR)/main.bin
	# compile done
	
.PHONY: clean
clean:
	# Remoe everything except source files
	rm -f -r $(BUILD_DIR)

.PHONY: font
font:
	#convert font
	rm -f src/font.h
	touch src/font.h
	echo -n "const " >> src/font.h
	xxd -i src/font_en.ch8 >> src/font.h

.PHONY: flash
flash:
	PCProg.exe COM18 build/main.bin
