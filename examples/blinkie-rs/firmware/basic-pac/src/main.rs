//! Basic PAC example: uses the [`avr-device`](https://github.com/Rahix/avr-device)
//! Peripheral Access Crate (PAC) for typed, safe register access instead of raw
//! pointer writes. Drives PB3 low and goes into a spinning loop.

#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[avr_device::entry]
fn main() -> ! {
    let dp = avr_device::avr128db48::Peripherals::take().unwrap();
    dp.PORTB.dirset().write(|w| w.pb3().set_bit());
    dp.PORTB.outclr().write(|w| w.pb3().set_bit());
    loop {}
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}
