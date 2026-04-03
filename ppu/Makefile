TARGET = Main

MCU = atmega328

PROGRAMMER = usbasp

F_CPU = 16000000UL

CC = avr-gcc
OBJCOPY = avr-objcopy
AVRDUDE = avrdude

CFLAGS = -Wall -Wextra -Wpedantic -Os -mmcu=$(MCU) -DF_CPU=$(F_CPU)
LDFLAGS = -Wl,-Ttext=0x0000

all: $(TARGET).hex $(TARGET).S

$(TARGET).elf: $(TARGET).S
	$(CC) $(CFLAGS) $(LDFLAGS) -nostartfiles -o $(TARGET).elf $(TARGET).S

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O ihex -R .eeprom $(TARGET).elf $(TARGET).hex

flash: $(TARGET).hex
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:w:$(TARGET).hex:i

fuse:
	$(AVRDUDE) -c ${PROGRAMMER} -B 32 -p ${MCU} -U hfuse:w:0xDE:m -U lfuse:w:0xFF:m

clean:
	del $(TARGET).elf $(TARGET).hex
