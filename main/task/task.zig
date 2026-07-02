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
pub const Task = struct {
    // THE critical field. When a task is paused, its registers get
    // pushed onto its own stack, and the final stack-pointer value
    // is stored HERE. To resume, we load this back into sp.
    // Must stay the FIRST field (offset 0) — the assembly switch
    // will read/write it at offset 0 from the task pointer.
    saved_sp: usize,

    // the task's private stack: where its function calls and locals
    // live while it runs. a slice = pointer + length, so it carries
    // both where the stack is and how big it is.
    stack: []u8,

    state: TaskState,
    id: u32,
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
    const stack = try allocator.alloc(u8, stack_size);

    // grab the next free slot and fill it
    const t = &tasks[num_tasks];
    t.* = Task{
        .saved_sp = 0, // placeholder — real value comes with priming (next step)
        .stack = stack,
        .state = .ready,
        .id = id,
    };
    num_tasks += 1;
    return t;
}
