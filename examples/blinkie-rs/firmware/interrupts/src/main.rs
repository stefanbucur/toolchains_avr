#![no_std]
#![no_main]
#![feature(abi_avr_interrupt)]

use core::panic::PanicInfo;

use avr_device::avr128db48::Peripherals;

const F_CPU_HZ: u32 = 4_000_000;

#[inline(always)]
fn delay_ms(ms: u32) {
    avr_device::asm::delay_cycles(ms * (F_CPU_HZ / 1_000));
}

#[avr_device::entry]
fn main() -> ! {
    let dp = Peripherals::take().unwrap();

    // LED on PB3: output, off.
    dp.PORTB.dirset().write(|w| w.pb3().set_bit());
    dp.PORTB.outclr().write(|w| w.pb3().set_bit());
    // Button on PB2: input, pull-up, falling-edge interrupt.
    dp.PORTB
        .pin2ctrl()
        .write(|w| w.pullupen().set_bit().isc().falling());

    // Idle sleep: wake on the port interrupt.
    dp.SLPCTRL
        .ctrla()
        .write(|w| w.smode().idle().sen().set_bit());

    unsafe {
        avr_device::interrupt::enable();
    }

    loop {
        avr_device::asm::sleep();
    }
}

#[avr_device::interrupt(avr128db48)]
fn PORTB_PORT() {
    // SAFETY: main only sleeps after setup, and these are atomic register writes.
    let portb = unsafe { Peripherals::steal().PORTB };
    if portb.intflags().read().pb2().bit_is_set() {
        delay_ms(10);
        if portb.in_().read().pb2().bit_is_clear() {
            portb.outtgl().write(|w| w.pb3().set_bit());
        }
        portb.intflags().write(|w| w.pb2().set_bit());
    }
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}
