/* kernel/context.S — the context switch proper.
 *
 *   void switchContext(usize *old_sp, usize new_sp);
 *
 * Pushes the 12 callee-saved s-registers + ra, stores sp through old_sp,
 * loads new_sp, pops the same 13 words, ret.
 *
 * The push/pop ORDER MUST MATCH TrapFrame in context.zig field-for-field —
 * s0..s11 then ra, ra at the highest address so `ret` lands on the entry
 * point primeStack wrote there.
 *
 * EMPTY STUB — not yet written.
 */
