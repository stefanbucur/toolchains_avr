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

#define F_CPU 4000000UL  // Define frequency for delay functions.

#include "src/pulse/button.h"

#include <avr/interrupt.h>
#include <avr/io.h>
#include <util/delay.h>

static button_callback_t s_on_press;

// On the AVR128DB48 Curiosity Nano, the button is connected to PB2.
//
// Installs the PORTB interrupt handler for the button press. The supplied
// callback is invoked (from interrupt context) each time a press is detected.
void button_initialize(button_callback_t on_press) {
    s_on_press = on_press;

    // Set PB2 as input.
    PORTB.DIRCLR = PIN2_bm;

    // Enable pull-up and falling edge interrupt.
    PORTB.PIN2CTRL = PORT_PULLUPEN_bm | PORT_ISC_FALLING_gc;
}

ISR(PORTB_PORT_vect) {
    // Check if PB2 triggered the interrupt.
    if (PORTB.INTFLAGS & PIN2_bm) {
        // Simple debounce: wait 10ms and check if button is still pressed.
        _delay_ms(10);
        if (!(PORTB.IN & PIN2_bm)) {  // If PB2 is still LOW (pressed).
            if (s_on_press) {
                s_on_press();
            }
        }

        // Clear the interrupt flag (must write 1 to clear).
        PORTB.INTFLAGS = PIN2_bm;
    }
}
