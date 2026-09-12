// kernel/trap.zig — Zig half of the trap handler.
//
// trap.S saves registers and calls in here with a pointer to the saved
// frame. Decodes mcause into: interrupt (timer -> sched tick) vs
// exception (fault -> panic, or ecall -> ipc.zig).
//
// EMPTY STUB — not yet written.
