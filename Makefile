.PHONY:all clean run gdb

all: boot.img

boot.img: boot
	dd if=/dev/zero of=boot.img bs=512 count=2
	dd if=boot of=boot.img conv=notrunc
	dd if=message.data of=boot.img seek=1 conv=notrunc
	
boot: boot.bin
	cp boot.bin boot
	../test/sign boot

boot.bin: boot.o main.o
	ld -N -e start -Ttext=0x7c00 -m elf_i386 -o boot.elf boot.o main.o
	objcopy -S -O binary -j .text boot.elf boot.bin

boot.o: boot.S
	cc -m32 -c -o boot.o boot.S

main.o: main.c
	cc -m32 -fno-builtin -fno-pic -nostdinc -c -o main.o main.c

run:
	qemu-system-i386 -drive file=boot.img,format=raw -monitor stdio

gdb:
	qemu-system-i386 -drive file=boot.img,format=raw -monitor stdio -S -s

clean:
	rm -f boot.bin boot.img boot boot.elf main.o boot.o
