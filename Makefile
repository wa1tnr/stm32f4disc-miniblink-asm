
PROJECT=miniblink

AS=arm-none-eabi-as
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy

OBJECTS=miniblink.o

rom.hex: $(PROJECT).out
	$(OBJCOPY) -O ihex $(PROJECT).out $(PROJECT).hex
	$(OBJCOPY) -I ihex -O binary $(PROJECT).hex $(PROJECT).bin

$(PROJECT).out: $(OBJECTS)
	$(LD) -v -T stm32f4-discovery.ld -nostartfiles -o $(PROJECT).out $(OBJECTS)

.s.o:
	$(AS) -mthumb -mcpu=cortex-m4 $< -o $@

binfile: miniblink.hex
	arm-none-eabi-objcopy -I ihex -O binary miniblink.hex miniblink.bin

clean:
	rm -f *.o *.out *.bin *.hex *~

install: miniblink.bin
	dfu-util -a 0 --dfuse-address 0x08000000 -D miniblink.bin

forth:
	dfu-util -a 0 --dfuse-address 0x08000000 -D stm32F4eForth720.bin

flash: rom.hex
	openocd -f interface/stlink-v2.cfg \
	        -f board/stm32f4discovery.cfg \
	        -c "init" -c "reset init" \
	        -c "flash write_image erase $(PROJECT).hex" \
	        -c "reset" \
	        -c "shutdown" 

