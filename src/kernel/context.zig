const std = @import("std");
const Task = @import("task.zig").Task;

// The exact register frame a task's stack holds when paused.
// extern struct = guaranteed C-ABI layout, fields in declared order.
// This IS the contract: primeStack writes it, the switch assembly reads it.
// Order matters — it must match the order the assembly pushes/pops.
pub const TrapFrame = extern struct {
    s0: usize,
    s1: usize,
    s2: usize,
    s3: usize,
    s4: usize,
    s5: usize,
    s6: usize,
    s7: usize,
    s8: usize,
    s9: usize,
    s10: usize,
    s11: usize,
    ra: usize, // last field = highest address = ret target
};

pub fn primeStack(task: *Task, entry: *const fn () void) void {
    // convert the stack pointer to a number so we can do math
    const base = @intFromPtr(task.stack_ptr);

    // top of the stack = base + length (stacks grow DOWN from here)
    const raw_top = base + task.stack_len;

    // align DOWN to 16 bytes: clear the low 4 bits.
    // ~0xF is the mask ...11110000 — ANDing clears the bottom nibble.
    const top = raw_top & ~@as(usize, 0xF);

    // reserve exactly one frame's worth, aligned.
    // @sizeOf(TrapFrame) = 13 × 4 = 52; round the sp down to 16.
    const frame_addr = (top - @sizeOf(TrapFrame)) & ~@as(usize, 0xF);

    // treat that address AS a TrapFrame — the compiler now knows
    // where every field lives. no hand-computed offsets.
    const frame: *TrapFrame = @ptrFromInt(frame_addr);

    // fresh task: all saved registers zero
    frame.* = std.mem.zeroes(TrapFrame); // all s-registers → 0

    // ra → entry function. this is the whole trick:
    // when the switch pops this frame and does `ret`, it jumps here.
    frame.ra = @intFromPtr(entry);

    task.saved_sp = frame_addr;
}

// The register save/restore half of the switch lives in context.S and is
// called from here once sched.zig exists:
//   extern fn switchContext(old_sp: *usize, new_sp: usize) void;
