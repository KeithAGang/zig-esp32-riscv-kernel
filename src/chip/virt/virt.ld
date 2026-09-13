/* chip/virt/virt.ld
 *
 * Linker script for QEMU's RISC-V "virt" board. Numbers here must match
 * chip/virt/layout.zig exactly — this file has no way to import that
 * constant, so if you change one, change both. (This duplication is
 * exactly what build.zig will generate away, once a second chip exists
 * and copy-pasted .ld files start actually drifting.)
 */

ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 500K
}

SECTIONS
{
  /* boot.S's _start MUST end up here, first, or QEMU jumps into garbage.
   * boot.S marks its entry code with .section .text.init to land here. */
  .text : {
    KEEP(*(.text.init))
    *(.text*)
  } > RAM

  .rodata : {
    *(.rodata*)
  } > RAM

  .data : {
    *(.data*)
  } > RAM

  /* zeroed globals: boot.S reads _bss_start/_bss_end to know what to clear */
  .bss : {
    _bss_start = .;
    *(.bss*)
    *(COMMON)
    _bss_end = .;
  } > RAM

  /* stack: grows DOWN, so _stack_top (high addr) is where sp starts,
   * _stack_bottom (low addr) is where it would overflow into the arena */
  . = ALIGN(16);
  _stack_bottom = .;
  . += 16K;
  _stack_top = .;

  /* kernel arena: ALIGN(128K) forces this address to be a multiple of
   * 128K, which is exactly the NAPOT requirement (power-of-two size,
   * aligned to its own size) — this region is legal as a single PMP
   * entry the moment pmp.zig exists */
  . = ALIGN(128K);
  _arena_start = .;
  . += 128K;
  _arena_end = .;
}
