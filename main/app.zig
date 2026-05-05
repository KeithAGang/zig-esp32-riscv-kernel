const std = @import("std");
const c = @import("idf_c/idf_c.zig").c;

// ---------------------------------------------------------
// THE VAULT: Global Kernel Memory State
// ---------------------------------------------------------
var kernel_allocator_state: std.heap.FixedBufferAllocator = undefined;

// This is the ONLY allocator that the os?/kernel? and Drivers are allowed to use
pub var kernel_allocator: std.mem.Allocator = undefined;

export fn app_main() void {
    c.esp_log_write(c.ESP_LOG_INFO, "BOOT", "Stage 2 Bootloader finished. Celestial OS Hijacking CPU...\n");
    // 1. THE USURP-ING!
    // We ask the ESP#@ hardware for 100 Kilobytes of fast internal SRAM
    // c.MALLOC_CAP_INTERNAL ensures it doesn't put us in the slow esternal SPI RAM.
    const arena_size = 100 * 1024;
    const raw_ptr = c.heap_caps_malloc(arena_size, c.MALLOC_CAP_INTERNAL | c.MALLOC_CAP_8BIT);

    if (raw_ptr == null) {
        c.esp_log_write(c.ESP_LOG_ERROR, "BOOT", "FATAL: Hardware refused kernel memory allocation!\n");
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

    c.esp_log_write(c.ESP_LOG_INFO, "BOOT", "Kernel Arena initialized: %d bytes at %p\n", @as(c_int, arena_size), raw_ptr);

    // --- SANITY TEST ---
    // Let's prove Zig owns the memory by allocating a slice from our new Bank Manager.
    const test_buffer = kernel_allocator.alloc(u8, 256) catch {
        @panic("Kernel Allocator Corrupted!");
    };
    _ = test_buffer;
    c.esp_log_write(c.ESP_LOG_INFO, "BOOT", "Sanity Check Passed. Zig is in absolute control.\n");
    // -------------------

    c.esp_log_write(c.ESP_LOG_INFO, "BOOT", "Entering Microkernel L4 Event Loop...\n");

    // 4. THE EVENT LOOP
    // We refuse to return to FreeRTOS. We own the main thread forever.
    while (true) {

        // TODO: Drain IPC Mailboxes here
        // TODO: Render Compositor here

        // (For now, we yield 10ms to the FreeRTOS idle task just so the
        // hardware watchdog timer doesn't panic and reboot the chip.
        // We will disable the watchdogs entirely later.)
        c.vTaskDelay(1);
    }
}
