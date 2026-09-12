// src/chip/virt/mod.zig — virt chip support.
//
// Implements the interface hal.zig checks for: console, timer, trap
// plumbing. Pairs with layout.zig in this directory for addresses.
//
// EMPTY STUB — not yet written.
//
// TARGET: qemu-system-riscv32 -machine virt.
// Console is an ns16550a at 0x1000_0000 — THR at +0, LSR at +5, bit 5 =
// THR empty. Six lines, no init needed; QEMU's is already configured.
