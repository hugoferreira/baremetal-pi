SRC_DIR = src
BUILD_DIR = build

C_SRCS = $(wildcard $(SRC_DIR)/*.c)
S_SRCS = $(wildcard $(SRC_DIR)/*.S)
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(C_SRCS)) \
       $(patsubst $(SRC_DIR)/%.S, $(BUILD_DIR)/%.o, $(S_SRCS))

CC = clang --target=aarch64-elf
CFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -mcpu=cortex-a53+nosimd -g

.PHONY: all setup clean run debug gdb

all: setup $(BUILD_DIR)/kernel8.img

setup:
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/kernel8.img: $(BUILD_DIR)/kernel8.elf
	llvm-objcopy -O binary $(BUILD_DIR)/kernel8.elf $(BUILD_DIR)/kernel8.img

$(BUILD_DIR)/kernel8.elf: $(OBJS)
	ld.lld -m aarch64elf -nostdlib $^ -T $(SRC_DIR)/link.ld -o $(BUILD_DIR)/kernel8.elf

clean:
	rm -rf $(BUILD_DIR)

run: $(BUILD_DIR)/kernel8.img
	qemu-system-aarch64 -M raspi3b -kernel $(BUILD_DIR)/kernel8.img -nographic

debug: $(BUILD_DIR)/kernel8.img
	qemu-system-aarch64 -M raspi3b -kernel $(BUILD_DIR)/kernel8.img -nographic -s -S

gdb: $(BUILD_DIR)/kernel8.img
	aarch64-elf-gdb $(BUILD_DIR)/kernel8.elf -ex "target remote :1234" -ex "break _start" -ex "continue"
