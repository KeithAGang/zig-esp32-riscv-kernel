const std = @import("std");
const uart = @import("../uart/uart.zig");

// The lifecycle states a task can be in.
// The scheduler will read this later to decide who runs.
// backed by u8 so it's exactly one byte — cheap
pub const TaskState = enum(u8) {
    ready, // eligible to run, waiting its turn
    running, // currently on the CPU
    blocked, // waiting for something (IPC, timer) — skip it
    dead, // finished — reclaim it
};

// One task. This is the whole "thread" as far as the kernel cares.
// extern struct: C-ABI layout. Fields stay in declared order,
// saved_sp is GUARANTEED at offset 0. The assembly depends on this.
pub const Task = extern struct {
    saved_sp: usize, // offset 0 — the switch reads/writes here
    stack_ptr: [*]u8, // extern structs can't hold a slice ([]u8);
    stack_len: usize, // so we split the slice into ptr + len
    state: TaskState,
    id: u32,
};

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

// ---- the task table ----
// A fixed global array. The table lives forever and has a known max,
// so it does NOT come from the allocator — it's static kernel memory.
// (Stacks WILL come from the allocator later; the table itself is static.)
pub const MAX_TASKS = 16;

pub var tasks: [MAX_TASKS]Task = undefined;
pub var num_tasks: usize = 0;

// Create a task: carve a stack from the given allocator, record it
// in the table. Takes the allocator explicitly — the caller decides
// WHERE the stack memory comes from (kernel arena now; maybe fast
// SRAM vs PSRAM later on the P4).
pub fn createTask(
    allocator: std.mem.Allocator,
    id: u32,
    stack_size: usize,
) !*Task {
    // guard: don't overflow the fixed table
    if (num_tasks >= MAX_TASKS) return error.TooManyTasks;

    // carve the stack from the arena — this is your flat-array bump
    const stack = try allocator.alignedAlloc(u8, .@"16", stack_size);

    // grab the next free slot and fill it
    const t = &tasks[num_tasks];
    t.* = Task{
        .saved_sp = 0, // placeholder — real value comes with priming (next step)
        .stack_ptr = stack.ptr,
        .stack_len = stack.len,
        .state = .ready,
        .id = id,
    };
    num_tasks += 1;
    return t;
}

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
