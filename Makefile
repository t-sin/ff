PROGRAM=ff

AS=arm-linux-gnueabi-as
LD=arm-linux-gnueabi-ld

$(PROGRAM): ff.o
	$(LD) $(LDFLAGS) ff.o -o $@

.o:.s
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: clean

clean:
	rm ff
	rm ff.o
