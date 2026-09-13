// chip/virt/layout.zig
//
// Memory map for QEMU's RISC-V "virt" board — a fixed board model defined
// in QEMU's own source (hw/riscv/virt.c), not a real chip. VIRT_DRAM base
// and VIRT_UART0 base are architectural constants for this board and are
// stable across QEMU versions. RAM *size* is whatever we pass via -m, so
// it's a constant we own — build.zig must pass exactly this value.

pub const ram_origin: usize = 0x8000_0000; // was 0x8000_0000; leaves first 2MB
// for QEMU's auto-generated FDT, which the "virt" machine places at the true
// RAM base (0x80000000) regardless of where our own code starts. This offset
// is a virt-tooling artifact — the C3 and P4 boot straight the built image
// with nothing else contending for RAM, so this line has no counterpart
// once the QEMU port is done.

pub const ran_length: usize = 500 * 1024; // must match `-m` in build.zig; deliberately small
// to rehearse the memory pressure of the eventual C3 target (~400KB SRAM)

pub const stack_size: usize = 16 * 1024; // 16-bit aligned memory per RV32 ABI
pub const arena_size: usize = 128 * 1024; // NAPOT-aligned

// ns16550a UART, VIRT_UART0 base, hw/riscv/virt.c. IRQ 10 (UART0_IRQ),
// unused until trap.zig/PLIC exist.
pub const uart_base: usize = 0x1000_0000;
