// main.zig

const hal = @import("hal.zig");

export fn kmain() noreturn {
    hal.consoleInit();
    const msg = "boot ok\n";
    for (msg) |c| hal.consolePutc(c);
    while (true) {}
}
