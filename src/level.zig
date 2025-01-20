const std = @import("std");
const Assets = @import("assets/assets.zig");
const Image = @import("assets/image.zig").Image;

pub const Tile = union(enum) {
    wall: *const Image,
    empty: struct {
        floor: *const Image,
        ceiling: *const Image,
    },
};

pub const Level = struct {
    width: usize,
    height: usize,
    tiles: std.ArrayList(Tile),

    const Self = @This();

    pub fn get_tile(self: *const Self, x: usize, y: usize) ?Tile {
        if (x >= self.width or y >= self.height) {
            return null;
        }

        return self.tiles.items[y * self.width + x];
    }
};

pub fn generate(allocator: std.mem.Allocator, assets: *const Assets, width: usize, height: usize) !Level {
    var tiles = try std.ArrayList(Tile).initCapacity(allocator, width * height);

    for (0..height) |y| {
        for (0..width) |x| {
            const is_edge = x == 0 or x == width - 1 or y == 0 or y == height - 1;
            if (is_edge) {
                try tiles.append(.{ .wall = &assets.block });
            } else {
                if (x == 5 and y == 5) {
                    try tiles.append(.{ .empty = .{
                        .floor = &assets.block,
                        .ceiling = &assets.floor2,
                    } });
                    continue;
                }

                if ((y + x) % 2 == 0) {
                    try tiles.append(.{ .empty = .{
                        .floor = &assets.floor1,
                        .ceiling = &assets.floor2,
                    } });
                } else {
                    try tiles.append(.{ .empty = .{
                        .floor = &assets.floor2,
                        .ceiling = &assets.floor1,
                    } });
                }
            }
        }
    }

    return .{
        .width = width,
        .height = height,
        .tiles = tiles,
    };
}
