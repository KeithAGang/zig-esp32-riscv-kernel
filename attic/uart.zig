const std = @import("std");
const builtin = @import("builtin");

// 1. THE COMPTIME HARDWARE CHECK
// This block runs inside the compiler, BEFORE the binary is generated.
// It checks your `build.zig` target and bakes the correct address into the final
// machine code. There is ZERO runtime performance cost for this if/else statement.
const UART0_BASE: usize = block: {
    const cpu_name = builtin.cpu.model.name;

    if (std.mem.eql(u8, cpu_name, "esp32c3")) {
        break :block 0x6000_0000; // Physical address for C3
    } else if (std.mem.eql(u8, cpu_name, "esp32p4")) {
        break :block 0x5000_0000; // Physical address for P4 (Placeholder)
    } else {
        @compileError("Unsupported CPU: This µKernel requires esp32c3 or esp32p4");
    }
};

// 2. THE MMIO HIJACK (The 'volatile' Pointers)
// We cast the raw physical addresses into volatile pointers so the compiler
// generates raw RISC-V 'sw' and 'lw' instructions instead of optimizing them away.
const UART0_FIFO = @as(*volatile u32, @ptrFromInt(UART0_BASE));
const UART0_STATUS = @as(*volatile u32, @ptrFromInt(UART0_BASE + 0x0004));

pub const Uart = struct {

    // Writes a single byte
    pub fn putc(c: u8) void {
        while (true) {
            const status = UART0_STATUS.*;
            const tx_fifo_cnt = (status >> 16) & 0x3FF;
            if (tx_fifo_cnt < 127) break;
        }

        UART0_FIFO.* = c;
    }

    // Writes an entire string
    pub fn print(str: []const u8) void {
        for (str) |c| {
            putc(c);
        }
    }
};

// 3. THE BULLETPROOF ZIG 0.16 FIX
// We bypass the unstable Writer interface completely. We format into
// a 1KB stack buffer and hand the raw string directly to the hardware.

// Emulates C++23 std::print
pub fn print(comptime format: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;

    // bufPrint is entirely stable. It safely writes to our array.
    const text = std.fmt.bufPrint(&buf, format, args) catch {
        // If our string is longer than 1024 bytes, we catch the error
        // safely instead of crashing the kernel.
        Uart.print("[UART ERR: String too long!]");
        return;
    };

    // Send the formatted string to the silicon
    Uart.print(text);
}

// Emulates C++23 std::println
pub fn println(comptime format: []const u8, args: anytype) void {
    print(format, args);
    Uart.putc('\n');
}
