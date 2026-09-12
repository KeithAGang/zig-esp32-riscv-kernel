# Hardware notes

Running log of register addresses, bit layouts, and TRM section numbers,
recorded as they're confirmed. Anything not confirmed against a document is
marked UNVERIFIED — the point of this file is to stop placeholder addresses
from quietly becoming load-bearing.

## qemu virt (riscv32)

| What | Address | Source |
|---|---|---|
| ns16550a UART | `0x1000_0000` | QEMU `hw/riscv/virt.c` |
| CLINT | `0x0200_0000` | QEMU `hw/riscv/virt.c` |
| RAM base | `0x8000_0000` | QEMU `hw/riscv/virt.c` |

ns16550a registers, offsets from base: THR/RBR +0, IER +1, FCR +2, LCR +3,
MCR +4, LSR +5. LSR bit 5 = THR empty, so TX is: spin until `LSR & 0x20`,
then store the byte to +0.

## ESP32-C3

| What | Address | Source |
|---|---|---|
| UART0 | `0x6000_0000` | carried over from `attic/uart.zig`, UNVERIFIED against TRM |

Offsets used by the old driver: FIFO +0x00, STATUS +0x04 with TX FIFO count
in bits 16..25. Needs a TRM section number.

## ESP32-P4

| What | Address | Source |
|---|---|---|
| UART0 | `0x5000_0000` | PLACEHOLDER in `attic/uart.zig` — do not trust |

The P4 has an FPU. ESP-IDF builds it `-mabi=ilp32f` (hard single-precision
float); a Zig target query has to match or objects won't link.

## TODO

- [ ] C3 UART0 base + register offsets, with TRM section
- [ ] P4 UART0 base — replace the placeholder
- [ ] mtime/mtimecmp for each target
- [ ] PMP region count and granularity per chip
