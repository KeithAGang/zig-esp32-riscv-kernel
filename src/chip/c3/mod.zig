// src/chip/c3/mod.zig — c3 chip support.
//
// Implements the interface hal.zig checks for: console, timer, trap
// plumbing. Pairs with layout.zig in this directory for addresses.
//
// EMPTY STUB — not yet written.
//
// TARGET: ESP32-C3. UART0 MMIO at 0x6000_0000 (FIFO +0x00, STATUS +0x04,
// TX count = bits 16..25). Working driver to lift: attic/uart.zig.
