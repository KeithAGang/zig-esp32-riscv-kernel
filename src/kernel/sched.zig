// kernel/sched.zig — the scheduler.
//
// Picks the next .ready task from task.zig's table and calls
// context.S's switchContext. Round-robin to start; the timer interrupt
// in trap.zig drives the tick.
//
// EMPTY STUB — not yet written.
