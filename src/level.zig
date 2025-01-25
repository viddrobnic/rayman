const std = @import("std");
const Assets = @import("assets/assets.zig");
const Image = @import("assets/image.zig").Image;

const GRID_SIZE = 3;
const SIZE = 60;
const MIN_ROOM_SIZE = 5;
const MIN_PADDING = 2;

pub const Tile = union(enum) {
    wall: *const Image,
    empty: struct {
        floor: *const Image,
        ceiling: *const Image,
    },
};

pub const Room = struct {
    start_x: usize,
    start_y: usize,
    width: usize,
    height: usize,
};

pub const Level = struct {
    width: usize,
    height: usize,

    tiles: std.ArrayList(Tile),

    rooms: std.ArrayList(Room),

    const Self = @This();

    pub fn get_tile(self: *const Self, x: usize, y: usize) ?Tile {
        if (x >= self.width or y >= self.height) {
            return null;
        }

        return self.tiles.items[y * self.width + x];
    }
};

pub fn generate(allocator: std.mem.Allocator, seed: u64, assets: *const Assets) !Level {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    var tiles = try std.ArrayList(Tile).initCapacity(allocator, SIZE * SIZE);
    for (0..SIZE * SIZE) |_| {
        try tiles.append(.{ .wall = &assets.red });
    }

    var rooms = try std.ArrayList(Room).initCapacity(allocator, GRID_SIZE * GRID_SIZE);

    for (0..GRID_SIZE) |room_y| {
        for (0..GRID_SIZE) |room_x| {
            const room = generate_room(&tiles, room_x, room_y, rand, assets);
            try rooms.append(room);
        }
    }

    return .{
        .width = SIZE,
        .height = SIZE,
        .tiles = tiles,
        .rooms = rooms,
    };
}

fn generate_room(tiles: *std.ArrayList(Tile), room_x: usize, room_y: usize, rand: std.Random, assets: *const Assets) Room {
    const room_size = SIZE / GRID_SIZE;
    const start_x = room_x * room_size;
    const start_y = room_y * room_size;

    const width = rand.intRangeAtMost(usize, MIN_ROOM_SIZE, room_size - 2 * MIN_PADDING);
    const height = rand.intRangeAtMost(usize, MIN_ROOM_SIZE, room_size - 2 * MIN_PADDING);

    const offset_x = rand.intRangeAtMost(usize, MIN_PADDING, room_size - width - MIN_PADDING);
    const offset_y = rand.intRangeAtMost(usize, MIN_PADDING, room_size - height - MIN_PADDING);

    for ((start_y + offset_y)..(start_y + offset_y + height)) |y| {
        for ((start_x + offset_x)..(start_x + offset_x + width)) |x| {
            const idx = y * SIZE + x;
            tiles.items[idx] = .{ .empty = .{
                .floor = &assets.floor1,
                .ceiling = &assets.floor2,
            } };
        }
    }

    return .{
        .start_x = start_x + offset_x,
        .start_y = start_y + offset_y,
        .width = width,
        .height = height,
    };
}
