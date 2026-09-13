// src/hal.zig — comptime chip selection.
//
// Exactly one chip/*/mod.zig is selected here from the build option
// (-Dchip=virt|c3|p4) and re-exported as `chip`. Kernel code imports
// hal.zig and never a chip module directly.
//
// Also the place for the comptime interface check: assert the selected
// module exposes the full surface (init, consolePutc, layout, timer, ...)
// so a half-finished port fails at compile time, not at 3am on hardware.

const build_options = @import("build_options");

pub const chip = switch (build_options.chip) {
    .virt => @import("chip/virt/mod.zig"),
    .c3 => @panic("ESP32 C3 not yet implimented!"),
    .p4 => @panic("ESP32 P4 not yet implimented!"),
};

comptime {
    if (!@hasDecl(chip, "consoleInit")) @compileError("chip missing consoleInit");
    if (!@hasDecl(chip, "consolePutc")) @compileError("chip missing consolePutc");
}

pub const consoleInit = chip.consoleInit;
pub const consolePutc = chip.consolePutc;
