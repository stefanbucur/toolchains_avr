#![no_std]
#![no_main]

use core::panic::PanicInfo;

const PORTB_BASE: usize = 0x0420;

const PORT_DIRSET_OFF: usize = 0x01;
const PORT_OUTCLR_OFF: usize = 0x06;

const PB3_BITMASK: u8 = 1 << 3;

fn main() -> ! {
    let portb_dirset = (PORTB_BASE + PORT_DIRSET_OFF) as *mut u8;
    let portb_outclr = (PORTB_BASE + PORT_OUTCLR_OFF) as *mut u8;

    // SAFETY: Nothing else is using these registers.
    unsafe {
        portb_dirset.write_volatile(PB3_BITMASK);
        portb_outclr.write_volatile(PB3_BITMASK);
    }

    loop {}
}

// This is the glue code that tells avr-libc where to find the main function.
#[unsafe(link_section = ".init9")]
#[unsafe(export_name = "main")]
pub unsafe extern "C" fn main_trampoline() {
    main()
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
