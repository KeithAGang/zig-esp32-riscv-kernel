const std = @import("std");
const c = @import("idf_c/idf_c.zig").c;
const uart = @import("uart/uart.zig");

// Tell Zig to use our custom function for ALL std.log calls globally.
pub const std_options: std.Options = .{
    .log_level = .debug,
    .logFn = kernelLog,
};

pub fn kernelLog(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const scope_prefix = if (scope == .default) "" else "(" ++ @tagName(scope) ++ "): ";
    const prefix = "[" ++ comptime level.asText() ++ "] " ++ scope_prefix;

    // Route the formatted text to our bare-metal RISC-V driver
    uart.print(prefix, .{});
    uart.println(format, args);
}

// ---------------------------------------------------------
// THE VAULT: Global Kernel Memory State
// ---------------------------------------------------------
var kernel_allocator_state: std.heap.FixedBufferAllocator = undefined;

// This is the ONLY allocator that the os?/kernel? and Drivers are allowed to use
pub var kernel_allocator: std.mem.Allocator = undefined;

export fn app_main() void {
    // Pause the OS for 8 seconds to let the Python socket connect.
    c.vTaskDelay(800);
    std.log.info("========================================", .{});
    std.log.info("Celestial OS RISC-V Kernel booting...", .{});

    // 1. THE USURP-ING!
    // We ask the ESP#@ hardware for 100 Kilobytes of fast internal SRAM
    // c.MALLOC_CAP_INTERNAL ensures it doesn't put us in the slow esternal SPI RAM.
    const arena_size = 100 * 1024;
    const raw_ptr = c.heap_caps_malloc(arena_size, c.MALLOC_CAP_INTERNAL | c.MALLOC_CAP_8BIT);

    if (raw_ptr == null) {
        std.log.err("Hardware refused kernel memory allocation!", .{});
        @panic("OOM");
    }

    // 2. The CLEANSING
    // We cast the dirty C `void*` into a strict, bounds-checked Zig byte slice.
    const memory_slice = @as([*]u8, @ptrCast(raw_ptr))[0..arena_size];

    // 3. THE BANK MANAGER
    // We initialize the Zig allocator over this slice
    // From now hence-forth, NO code is allowed to call C's malloc()
    kernel_allocator_state = std.heap.FixedBufferAllocator.init(memory_slice);
    kernel_allocator = kernel_allocator_state.allocator();

    std.log.info("Bank Manager allocated {d} bytes at 0x{X}", .{ arena_size, @intFromPtr(raw_ptr) });
    std.log.info("Entering infinite L4 loop...", .{});
    std.log.info("========================================\n", .{});

    // --- SANITY TEST ---
    // Let's prove Zig owns the memory by allocating a slice from our new Bank Manager.
    const test_buffer = kernel_allocator.alloc(u8, 256) catch {
        @panic("Kernel Allocator Corrupted!");
    };
    _ = test_buffer;

    std.log.info("BOOT: Sanity Check Passed. Zig is in absolute control.\n", .{});
    // -------------------

    std.log.info("BOOT: Entering Microkernel L4 Event Loop...\n", .{});

    // 4. THE EVENT LOOP
    // We refuse to return to FreeRTOS. We own the main thread forever.
    while (true) {

        // TODO: Drain IPC Mailboxes here
        // TODO: Render Compositor here

        // (For now, we yield 10ms to the FreeRTOS idle task just so the
        // hardware watchdog timer doesn't panic and reboot the chip.
        // We will disable the watchdogs entirely later.)
        c.vTaskDelay(100);
    }
}
