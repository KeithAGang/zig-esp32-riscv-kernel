// kernel/boot.zig — Zig side of the boot path.
//
// Called from boot.S once sp/.bss/.data are valid. Responsibilities:
//   * hand off to hal.init() for chip bring-up (console first)
//   * install the trap vector (mtvec -> trap.S)
//   * set up the static kernel arena
//   * call into main.zig's kernel entry
//
// EMPTY STUB — not yet written.
