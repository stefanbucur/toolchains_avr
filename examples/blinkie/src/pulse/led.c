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

#include "src/pulse/led.h"

#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdint.h>

// On the AVR128DB48 Curiosity Nano, the LED is connected to PB3.
//
// The LED is fully driven by the PWM functionality of the TCA0 timer, which is
// separate hardware that does not need CPU cycles. Therefore, the CPU can
// sleep and only wake up periodically to update the brightness value.

// Led initialization.
////////////////////////////////////////////////////////////////////////////////

static void led_pwm_initialize(void) {
    // Route TCA0 output to PORTB. PB3 will become WO3 of TCA0.
    PORTMUX.TCAROUTEA = PORTMUX_TCA0_PORTB_gc;

    TCA0.SPLIT.CTRLD = TCA_SPLIT_SPLITM_bm;

    // Enable PWM on WO3 (HCMPx bits map to WO{x+3}).
    TCA0.SPLIT.CTRLB = TCA_SPLIT_HCMP0EN_bm;
    TCA0.SPLIT.HPER = UINT8_MAX;
    TCA0.SPLIT.HCMP0 = 0;  // Start with the LED full on.

    // 4 MHz / 8 / 256 = 1953 Hz PWM frequency, which does not create visual
    // artifacts even when the LED is moved quickly. In contrast, 16 and 64
    // dividers create flickering when moving the LED.
    TCA0.SPLIT.CTRLA = TCA_SPLIT_CLKSEL_DIV8_gc | TCA_SPLIT_ENABLE_bm;
}

static void rtc_pit_initialize(void) {
    while (RTC.STATUS > 0);

    RTC.CLKSEL = RTC_CLKSEL_OSC32K_gc;
    while (RTC.PITSTATUS & RTC_CTRLBUSY_bm);
    RTC.PITCTRLA = RTC_PERIOD_CYC128_gc | RTC_PITEN_bm;
    RTC.PITINTCTRL = RTC_PI_bm;
}

void led_initialize(void) {
    // Set the LED pin as output.
    PORTB.DIRSET = PIN3_bm;

    led_pwm_initialize();
    rtc_pit_initialize();
}

// Led pulsing control.
////////////////////////////////////////////////////////////////////////////////

void led_pulse_toggle(void) {
    // Toggle the RTC Enable bit.
    // We must wait for the RTC to be ready before writing!
    while (RTC.PITSTATUS & RTC_CTRLBUSY_bm);
    RTC.PITCTRLA ^= RTC_PITEN_bm;
}

// Led pulsing logic.
////////////////////////////////////////////////////////////////////////////////

static void led_set_brightness(uint8_t brightness) {
    TCA0.SPLIT.HCMP0 = UINT8_MAX - brightness;
}

ISR(RTC_PIT_vect) {
    static volatile uint8_t brightness = 0;
    static volatile int8_t fade_direction = 1;

    RTC.PITINTFLAGS = RTC_PI_bm;

    brightness += fade_direction;
    if (brightness == 255) {
        fade_direction = -1;
    } else if (brightness == 0) {
        fade_direction = 1;
    }

    led_set_brightness(brightness);
}
