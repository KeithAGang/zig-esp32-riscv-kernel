// main/idf_c.zig
pub const c = @cImport({
    // Global Defines
    @cDefine("wint_t", "unsigned int");

    // RISC-V specific
    @cInclude("riscv/rv_utils.h");
    @cInclude("riscv/interrupt.h");
    @cInclude("esp_private/interrupt_intc.h");

    // FreeRTOS & ESP-IDF
    @cInclude("freertos/FreeRTOS.h");
    @cInclude("freertos/task.h");
    @cInclude("esp_log.h");
    // @cInclude("driver/uart.h");
    @cInclude("esp_heap_caps.h");
});
