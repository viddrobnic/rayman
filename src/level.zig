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

    connect_rooms(rooms.items, tiles.items, rand, assets);

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

fn connect_rooms(rooms: []Room, tiles: []Tile, rand: std.Random, assets: *const Assets) void {
    const MAX_ROOMS = GRID_SIZE * GRID_SIZE;

    // Indices of rooms in graph. Start with random room index.
    var in_graph: [MAX_ROOMS]usize = undefined;
    in_graph[0] = rand.uintLessThan(usize, MAX_ROOMS);

    // Number of rooms in graph.
    var nr_in_graph: usize = 1;

    while (nr_in_graph < MAX_ROOMS) {
        // Pick random room in graph.
        const idx_1 = in_graph[rand.uintLessThan(usize, nr_in_graph)];

        // Pick random neighbor not in graph
        var buffer: [MAX_ROOMS]usize = undefined;
        var neighbours = get_neighbours(idx_1, &buffer);

        // Remove neighbors already in graph
        var i: usize = 0;
        while (i < neighbours.len) {
            if (contains(usize, &in_graph, neighbours[i])) {
                neighbours[i] = neighbours[neighbours.len - 1];
                neighbours = neighbours[0 .. neighbours.len - 1];
            } else {
                i += 1;
            }
        }

        // There are no neighbors outside the graph.
        // We start from a different room
        if (neighbours.len == 0) {
            continue;
        }

        const idx_2 = neighbours[rand.uintLessThan(usize, neighbours.len)];

        draw_tunnel(rooms, tiles, idx_1, idx_2, assets);

        in_graph[nr_in_graph] = idx_2;
        nr_in_graph += 1;
    }
}

fn draw_tunnel(rooms: []Room, tiles: []Tile, idx_1: usize, idx_2: usize, assets: *const Assets) void {
    // TODO: Make connections correct.
    const start_idx = @min(idx_1, idx_2);
    const end_idx = @max(idx_1, idx_2);
    const start = rooms[start_idx];
    const end = rooms[end_idx];

    // Horizontal
    if (end_idx - start_idx == 1) {
        const start_x = start.start_x + start.width;
        const end_x = end.start_x + 1;
        const y = start.start_y + start.height / 2;
        for (start_x..end_x) |x| {
            tiles[y * SIZE + x] = .{ .empty = .{
                .floor = &assets.floor1,
                .ceiling = &assets.floor2,
            } };
        }
    }
    // Vertial
    else {
        const start_y = start.start_y + start.height;
        const end_y = end.start_y + 1;
        const x = start.start_x + start.width / 2;
        for (start_y..end_y) |y| {
            tiles[y * SIZE + x] = .{ .empty = .{
                .floor = &assets.floor1,
                .ceiling = &assets.floor2,
            } };
        }
    }
}

fn get_neighbours(idx: usize, buffer: []usize) []usize {
    var i: usize = 0;

    // Down
    if (idx >= GRID_SIZE) {
        buffer[i] = idx - GRID_SIZE;
        i += 1;
    }

    // Up
    if (idx + GRID_SIZE < GRID_SIZE * GRID_SIZE) {
        buffer[i] = idx + GRID_SIZE;
        i += 1;
    }

    // Left
    if (idx % GRID_SIZE != 0) {
        buffer[i] = idx - 1;
        i += 1;
    }

    // Right
    if (idx % GRID_SIZE != GRID_SIZE - 1) {
        buffer[i] = idx + 1;
        i += 1;
    }

    return buffer[0..i];
}

fn contains(comptime T: type, slice: []T, elt: T) bool {
    for (slice) |val| {
        if (val == elt) {
            return true;
        }
    }

    return false;
}
