#include <avr/io.h>

#define H_SYNC_PIN 5
#define V_SYNC_PIN 4

#define PIXEL_PIN 3

#define LINE_CNT_L R24
#define LINE_CNT_H R25
#define WAIT_CNT R20

#define ZERO_REG R16

.section .text
.ORG 0x0000
    RJMP RESET

RESET:
    LDI  R16, lo8(RAMEND)                        ; Initialise stack pointers
    OUT  _SFR_IO_ADDR(SPL), R16
    LDI  R16, hi8(RAMEND)
    OUT  _SFR_IO_ADDR(SPH), R16

    LDI  ZERO_REG, 0

    SBI  _SFR_IO_ADDR(DDRC), H_SYNC_PIN          ; Set H_SYNC_PIN to output mode and HIGH.
    SBI  _SFR_IO_ADDR(PORTC), H_SYNC_PIN
    SBI  _SFR_IO_ADDR(DDRC), V_SYNC_PIN          ; Set V_SYNC_PIN to output mode and HIGH.
    SBI  _SFR_IO_ADDR(PORTC), V_SYNC_PIN
    SBI  _SFR_IO_ADDR(DDRC), PIXEL_PIN           ; Set PIXEL_PIN to output mode.

    LDI  LINE_CNT_H, hi8(525)
    LDI  LINE_CNT_L, lo8(525)

    CLI

SYNC_PULSE:                                      ; --- Begin Sync Pulse ---
    CBI  _SFR_IO_ADDR(PORTC), H_SYNC_PIN         ; Begin H_SYNC pulse. (2 clocks)

    CPI  LINE_CNT_L, 34                          ; 1 clock
    CPC  LINE_CNT_H, ZERO_REG                    ; 1 clock
    BREQ WAIT_THREE_CLOCKS_AND_SET_VSYNC_LOW     ; if LINE_CNT == 34 then 2 clocks else 1 clock.
    CPI  LINE_CNT_L, 35                          ; 1 clock
    CPC  LINE_CNT_H, ZERO_REG                    ; 1 clock
    BREQ SET_VSYNC_LOW                           ; if LINE_CNT == 35 then 2 clocks else 1 clock.

    SBI  _SFR_IO_ADDR(PORTC), V_SYNC_PIN         ; 2 clocks
    RJMP VSYNC_IS_SET                            ; 2 clocks

WAIT_THREE_CLOCKS_AND_SET_VSYNC_LOW:
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock

SET_VSYNC_LOW:
    CBI  _SFR_IO_ADDR(PORTC), V_SYNC_PIN         ; 2 clocks
    NOP                                          ; 1 clock

VSYNC_IS_SET:                                    ; 12 clocks so far.
    LDI  WAIT_CNT, 16                            ; 1 clock

SYNC_PULSE_WAIT:
    DEC  WAIT_CNT                                ; 1 clock
    BRNE SYNC_PULSE_WAIT                         ; if WAIT_CNT /= 0 then 2 clocks else 1 clock.
    NOP                                          ; 1 clock
                                                 ; Total 61 clocks. (3.8125 microseconds on 16MHz; ideal: 3.8133 microseconds.)
                                                 ; --- End Sync Pulse ---
                                            
BACK_PORCH:                                      ; --- Begin Back Porch ---
    SBI  _SFR_IO_ADDR(PORTC), H_SYNC_PIN         ; End H_SYNC pulse. (2 clocks)
    LDI  WAIT_CNT, 9                             ; 1 clock
BACK_PORCH_WAIT:
    DEC  WAIT_CNT                                ; 1 clock
    BRNE BACK_PORCH_WAIT                         ; if WAIT_CNT /= 0 then 2 clocks else 1 clock.
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
                                                 ; Total 31 clocks. (1.9375 microseconds on 16MHz; ideal: 1.90665 microseconds.)
                                                 ; -- End Back Porch ---

ACTIVE_VIDEO:                                    ; -- Begin Active Video ---
    LDI  WAIT_CNT, 134                           ; 1 clock
    SBI _SFR_IO_ADDR(PORTC), PIXEL_PIN
ACTIVE_VIDEO_WAIT:
    DEC  WAIT_CNT                                ; 1 clock
    BRNE ACTIVE_VIDEO_WAIT                       ; if WAIT_CNT /= 0 then 2 clocks else 1 clock.
    ;NOP                                          ; 1 clock
    ;NOP                                          ; 1 clock
    NOP
    CBI _SFR_IO_ADDR(PORTC), PIXEL_PIN
                                                 ; Total 407 clocks. (25.4375 microseconds on 16MHz; ideal: 25.42204 microseconds.)
                                                 ; -- End Active Video ---

FRONT_PORCH:                                     ; --- Begin Front Porch ---
    SBIW LINE_CNT_L, 1                           ; 2 clocks
    BRNE LINE_CNT_NOT_ZERO                       ; if LINE_CNT /= 0 then 2 clocks else 1 clock.

    LDI  LINE_CNT_H, hi8(525)                    ; 1 clock
    LDI  LINE_CNT_L, lo8(525)                    ; 1 clock
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    RJMP SYNC_PULSE                              ; 2 clocks

LINE_CNT_NOT_ZERO:
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    NOP                                          ; 1 clock
    RJMP SYNC_PULSE                              ; 2 clocks
                                                 ; Total 10 clocks. (0.625 microseconds on 16MHz; ideal: 0.63555 microseconds.)
                                                 ; -- End Front Porch ---
