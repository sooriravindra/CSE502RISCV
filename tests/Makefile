ARCH=riscv64-unknown-linux-gnu-
CC=$(ARCH)gcc
OBJDUMP=$(ARCH)objdump
CFLAGS=-march=rv64im -O0 -Wno-implicit-int -nostdlib
OBJECT_FILES=test1 test2
.PHONY: all clean 
all : $(OBJECT_FILES)
clean:
	rm -f obj/*
%: %.c
	$(CC) $(CFLAGS) --static -o obj/$@ $<
	$(OBJDUMP) -S obj/$@ > obj/$@.s
