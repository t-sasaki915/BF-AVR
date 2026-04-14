#define F_CPU 24000000UL

#include <avr/io.h>
#include <util/delay.h>

void DMMLInit(void)
{
    _PROTECTED_WRITE(CLKCTRL.OSCHFCTRLA, CLKCTRL_FRQSEL_24M_gc);

    VPORTA_DIR |= (1 << 7);

    for (;;)
    {
        VPORTA_OUT |= (1 << 7);
        _delay_ms(1000);
        VPORTA_OUT &= ~(1 << 7);
        _delay_ms(1000);
    }
}
