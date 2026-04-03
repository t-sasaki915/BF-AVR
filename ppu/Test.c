#include <avr/interrupt.h>
#include <avr/io.h>

ISR(TIMER1_COMPA_vect)
{
    PORTB = ~PORTB;
}

int main(void)
{
    DDRB = (1 << PORTB1);

    OCR1A = 15624;
    TCCR1B = (1 << WGM12) | (1 << CS10) | (1 << CS12);
    TIMSK1 = (1 << OCIE1A);

    sei();

    for (;;)
    {
    }

    return 0;
}
