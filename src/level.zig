const std = @import("std");
const textures = @import("textures.zig");

const Texture = textures.Texture;

pub const Tile = union(enum) {
    wall: *const Texture,
    empty: struct {
        floor: *const Texture,
        ceiling: *const Texture,
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

pub fn generate(allocator: std.mem.Allocator, texture_manager: *const textures.TextureManager, width: usize, height: usize) !Level {
    var tiles = try std.ArrayList(Tile).initCapacity(allocator, width * height);

    for (0..height) |y| {
        for (0..width) |x| {
            const is_edge = x == 0 or x == width - 1 or y == 0 or y == height - 1;
            if (is_edge) {
                try tiles.append(.{ .wall = &texture_manager.red });
            } else {
                if ((y + x) % 2 == 0) {
                    try tiles.append(.{ .empty = .{
                        .floor = &texture_manager.floor1,
                        .ceiling = &texture_manager.floor2,
                    } });
                } else {
                    try tiles.append(.{ .empty = .{
                        .floor = &texture_manager.floor2,
                        .ceiling = &texture_manager.floor1,
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
