const std = @import("std");

const Color = @import("color.zig");
const screen = @import("screen.zig");

pub fn render(_: f32) !void {
    const color = Color.new(255, 0, 0);

    for (0..screen.height) |y| {
        for (0..screen.width) |x| {
            screen.draw_pixel(x, y, color);
        }
    }
}
