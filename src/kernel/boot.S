# kernel/boot.S
#
# The first instruction QEMU executes. Nothing is initialized: no stack,
# .bss is whatever garbage was in RAM. This file's only job is to fix
# that, then jump into kmain and never come back.

.section .text.init      # placed first by virt.ld's KEEP(*(.text.init))
.global _start           # matches ENTRY(_start) in virt.ld

_start:
    # 1. Stack pointer. Nothing below this line may call a function or
    #    touch the stack — sp is garbage until this executes.
    la sp, _stack_top

    # 2. Zero .bss. Compiled code assumes uninitialized globals start
    #    at zero; nothing guarantees that's true in raw RAM.
    la t0, _bss_start
    la t1, _bss_end
clear_bss:
    bgeu t0, t1, bss_done
    sw   zero, 0(t0)
    addi t0, t0, 4
    j    clear_bss
bss_done:

    # 3. Jump into Zig. `call` sets ra, but kmain must never return —
    #    there is nothing to return TO.
    call kmain

    # If kmain ever returns, something is badly wrong. Trap loudly
    # rather than executing whatever garbage follows in memory.
hang:
    j hang
