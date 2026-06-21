#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[avr_device::entry]
fn main() -> ! {
    let dp = avr_device::avr128db48::Peripherals::take().unwrap();

    dp.PORTB.dirset().write(|w| w.pb3().set_bit());
    dp.PORTB.outclr().write(|w| w.pb3().set_bit());

    dp.SLPCTRL.ctrla().write(|w| {
        w.smode().idle();
        w.sen().set_bit()
    });
    loop {
        avr_device::asm::sleep();
    }
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}
