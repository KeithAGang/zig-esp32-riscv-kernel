// src/chip/virt/mod.zig — virt chip support.
//
// Implements the interface hal.zig checks for: console, timer, trap
// plumbing. Pairs with layout.zig in this directory for addresses.

const layout = @import("layout.zig");

const UART_BASE: usize = layout.uart_base;
const THR: *volatile u8 = @ptrFromInt(UART_BASE + 0x00); // transmit holding register
const LSR: *volatile u8 = @ptrFromInt(UART_BASE + 0x05); // line status register
const LSR_THRE: u8 = 0x20; // bit 5, transmit holding register empty

pub fn consoleInit() void {
    // QEMU's ns16550 model on "virt" comes pre-configured — no baud/divisor
    // setup needed. C3/P4 will need a real init definition here.
}

pub fn consolePutc(c: u8) void {
    // while (LSR.* & LSR_THRE == 0) {} // poll until transmitter is ready
    THR.* = c;
}
