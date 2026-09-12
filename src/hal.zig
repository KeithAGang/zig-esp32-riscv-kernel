// src/hal.zig — comptime chip selection.
//
// Exactly one chip/*/mod.zig is selected here from the build option
// (-Dchip=virt|c3|p4) and re-exported as `chip`. Kernel code imports
// hal.zig and never a chip module directly.
//
// Also the place for the comptime interface check: assert the selected
// module exposes the full surface (init, consolePutc, layout, timer, ...)
// so a half-finished port fails at compile time, not at 3am on hardware.
//
// EMPTY STUB — not yet written.
