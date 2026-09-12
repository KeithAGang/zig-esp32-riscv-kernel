// src/chip/p4/mod.zig — p4 chip support.
//
// Implements the interface hal.zig checks for: console, timer, trap
// plumbing. Pairs with layout.zig in this directory for addresses.
//
// EMPTY STUB — not yet written.
//
// TARGET: ESP32-P4. UART base 0x5000_0000 was a PLACEHOLDER in the old
// driver — confirm against the TRM before trusting it (docs/hardware-notes.md).
// Note the P4 has an FPU: ilp32f ABI, hard single-precision float.
