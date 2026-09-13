# zig-esp32-riscv-kernel

A small microkernel for RISC-V microcontrollers, written in Zig. It is the
dissertation project *A Minimal Operating System Kernel with Runtime
Instruction Translation for Low-Cost RISC-V Microcontrollers*.

The end targets are the ESP32-P4 and ESP32-C3. There is no ESP-IDF, FreeRTOS
or CMake: `build.zig` is the whole build.

## Status

Early bring-up on **QEMU's RISC-V `virt` machine**. The kernel boots and
prints `boot ok` over the UART. That's all it does so far.

| Target | State |
| --- | --- |
| `virt` (QEMU) | boots, UART output |
| `c3` | not started |
| `p4` | not started |

## Requirements

- Zig 0.16.0 (stock, no fork)
- `qemu-system-riscv32`

## Build and run

```sh
zig build            # build zig-out/bin/kernel
zig build qemu       # run it under QEMU virt (Ctrl-A X to quit)
```

Select the chip with `-Dchip=virt|c3|p4` (default `virt`).

## Layout

```text
src/
  main.zig      kmain
  hal.zig       comptime chip selection
  kernel/       boot, traps, tasks, scheduler, IPC, PMP
  chip/<name>/  per-chip drivers, memory layout, linker script
attic/          old ESP-IDF-era code, not built
docs/           hardware notes
```

## Blog

Progress is written up at https://keith-dev-blog.pages.dev/blog, starting with
[QEMU virt, Part 1](https://keith-dev-blog.pages.dev/blog/2026-09-13-booting-on-qemu-virt-part-1).
