/* kernel/trap.S — mtvec entry point.
 *
 * The mscratch swap trick: mscratch holds 0 while in the kernel and the
 * task's kernel-stack pointer while in a task, so the handler can tell
 * which it interrupted without clobbering a register first.
 *
 *   csrrw sp, mscratch, sp   -> sp now kernel stack, mscratch holds task sp
 *   save caller-saved + a0-a7 to the frame
 *   mv a0, sp ; jal handleTrap   (trap.zig)
 *   restore, csrrw sp, mscratch, sp, mret
 *
 * EMPTY STUB — not yet written.
 */
