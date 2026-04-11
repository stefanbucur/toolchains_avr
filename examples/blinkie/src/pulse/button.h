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

#ifndef BLINKIE_SRC_PULSE_BUTTON_H_
#define BLINKIE_SRC_PULSE_BUTTON_H_

// Callback invoked when the button is pressed.
typedef void (*button_callback_t)(void);

// Initializes the button hardware. The supplied callback is invoked (from
// interrupt context) each time a press is detected.
void button_initialize(button_callback_t on_press);

#endif  // BLINKIE_SRC_PULSE_BUTTON_H_
