// Copyright 2026 The toolchains_avr authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Simple LED toggle example for the AVR128DB48 Curiosity Nano.
//
// The on-board button (PB2) toggles the on-board LED (PB3) on and off.
// No PWM or timers are used — the LED is driven directly as a GPIO output.

#define F_CPU 4000000UL  // Define frequency for delay functions.

#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/sleep.h>
#include <util/delay.h>

ISR(PORTB_PORT_vect) {
    if (PORTB.INTFLAGS & PIN2_bm) {
        // Simple debounce: wait 10ms and check if button is still pressed.
        _delay_ms(10);
        if (!(PORTB.IN & PIN2_bm)) {  // If PB2 is still LOW (pressed).
            // Toggle the LED on PB3.
            PORTB.OUTTGL = PIN3_bm;
        }

        // Clear the interrupt flag (must write 1 to clear).
        PORTB.INTFLAGS = PIN2_bm;
    }
}

int main(void) {
    // Initialize the LED port on PB3.
    PORTB.DIRSET = PIN3_bm;
    PORTB.OUTCLR = PIN3_bm;

    // Initialize the button on PB2 with pull-up and falling edge interrupt.
    PORTB.DIRCLR = PIN2_bm;
    PORTB.PIN2CTRL = PORT_PULLUPEN_bm | PORT_ISC_FALLING_gc;

    // Enable sleep in idle mode. The CPU wakes on every button interrupt.
    SLPCTRL.CTRLA = SLPCTRL_SMODE_IDLE_gc;
    SLPCTRL.CTRLA |= SLPCTRL_SEN_bm;

    sei();
    while (1) {
        sleep_cpu();
    }
}
