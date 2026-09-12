# attic

Code from the ESP-IDF era, kept for reference and deliberately **outside the
active build**. Nothing in `src/` imports from here. Zig only compiles what's
reachable from the build root, so these files cost nothing — they're just not
in the way while the trap handler is being written.

## `uart.zig`

Bare-metal MMIO UART for ESP32-C3 / ESP32-P4 — not an ESP-IDF driver call,
despite what the roadmap says. It writes `*volatile u32` directly:

- C3 base `0x6000_0000`, P4 base `0x5000_0000` (the P4 one was a placeholder)
- FIFO at +0x00, STATUS at +0x04, TX FIFO count in bits 16..25
- comptime chip dispatch on `builtin.cpu.model.name` — the pattern `hal.zig`
  replaces with a proper build option
- `print`/`println` format into a 1KB stack buffer via `std.fmt.bufPrint`,
  sidestepping the unstable Writer interface

Real salvage material for `src/chip/c3/mod.zig`. Wrong hardware entirely for
`chip/virt` (ns16550a, different register layout).

## `compositor.zig`

ANSI box-drawing over the UART. Month-eight work per the roadmap; revisit at
the console-server milestone.

Note it was **already broken** when it was parked: it calls
`uart.Terminal.print`, and `uart.zig` exposes `Uart`, not `Terminal`. Whatever
renamed that struct never came back to this file.
