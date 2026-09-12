const uart = @import("../uart/uart.zig");
const std = @import("std");

pub fn drawWindow(start_col: u16, start_row: u16, width: u16, height: u16) void {
    var buf: [32]u8 = undefined;

    // 1. Draw Top Border
    // Capture the exact slice returned by bufPrint
    const top_pos = std.fmt.bufPrint(&buf, "\x1B[{d};{d}H", .{ start_row, start_col }) catch return;
    uart.Terminal.print(top_pos); // Print ONLY the exact bytes!
    uart.Terminal.print("╭");

    for (0..(width - 2)) |_| uart.Terminal.print("─");
    uart.Terminal.print("╮");

    // 2. Draw Side Borders
    for (1..(height - 1)) |offset| {
        const current_row = start_row + @as(u16, @intCast(offset));

        const left_pos = std.fmt.bufPrint(&buf, "\x1B[{d};{d}H│", .{ current_row, start_col }) catch return;
        uart.Terminal.print(left_pos);

        const right_pos = std.fmt.bufPrint(&buf, "\x1B[{d};{d}H│", .{ current_row, start_col + width - 1 }) catch return;
        uart.Terminal.print(right_pos);
    }

    // 3. Draw Bottom Border
    const bot_pos = std.fmt.bufPrint(&buf, "\x1B[{d};{d}H", .{ start_row + height - 1, start_col }) catch return;
    uart.Terminal.print(bot_pos);
    uart.Terminal.print("╰");

    for (0..(width - 2)) |_| uart.Terminal.print("─");
    uart.Terminal.print("╯");
}
