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

#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/sleep.h>

#include "src/pulse/button.h"
#include "src/pulse/led.h"

int main(void) {
    led_initialize();
    button_initialize(led_pulse_toggle);

    // Enable sleep in idle mode when the SLEEP instruction is executed. This
    // will keep the timer hardware still running while the CPU is sleeping.
    SLPCTRL.CTRLA = SLPCTRL_SMODE_IDLE_gc;
    SLPCTRL.CTRLA |= SLPCTRL_SEN_bm;

    sei();
    while (1) {
        sleep_cpu();
    }
}
