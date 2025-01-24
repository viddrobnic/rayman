const std = @import("std");

const Assets = @import("assets/assets.zig");
const levels = @import("level.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const seed = std.time.timestamp();

    const assets = try Assets.init();
    const level = try levels.generate(allocator, @intCast(seed), &assets);
    defer level.tiles.deinit();

    display_level(&level);
}

fn display_level(level: *const levels.Level) void {
    for (0..level.height) |y| {
        for (0..level.width) |x| {
            const tile = level.get_tile(x, y).?;
            switch (tile) {
                .wall => std.debug.print("#", .{}),
                .empty => std.debug.print(" ", .{}),
            }
        }
        std.debug.print("\n", .{});
    }
}
