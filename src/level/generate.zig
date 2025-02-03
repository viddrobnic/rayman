const std = @import("std");

const level = @import("level.zig");
const assets = @import("../assets/assets.zig");
const Vec = @import("../vec.zig").Vec;

pub fn generate(
    allocator: std.mem.Allocator,
    seed: u64,
) !level.Level {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    var tiles = try std.ArrayList(level.Tile).initCapacity(allocator, level.SIZE * level.SIZE);
    for (0..level.SIZE * level.SIZE) |_| {
        const rdx = rand.uintLessThan(u8, 10);
        if (rdx == 0) {
            try tiles.append(.{ .wall = &assets.wall2 });
        } else {
            try tiles.append(.{ .wall = &assets.wall1 });
        }
    }

    var rooms = try std.ArrayList(level.Room).initCapacity(allocator, level.GRID_SIZE * level.GRID_SIZE);

    for (0..level.GRID_SIZE) |room_y| {
        for (0..level.GRID_SIZE) |room_x| {
            const room = generate_room(&tiles, room_x, room_y, rand);
            try rooms.append(room);
        }
    }

    connect_rooms(rooms.items, tiles.items, rand);

    return .{
        .width = level.SIZE,
        .height = level.SIZE,
        .tiles = tiles,
        .rooms = rooms,
    };
}

fn generate_room(tiles: *std.ArrayList(level.Tile), room_x: usize, room_y: usize, rand: std.Random) level.Room {
    const room_size = level.SIZE / level.GRID_SIZE;
    const start_x = room_x * room_size;
    const start_y = room_y * room_size;

    const width = rand.intRangeAtMost(usize, level.MIN_ROOM_SIZE, room_size - 2 * level.MIN_PADDING);
    const height = rand.intRangeAtMost(usize, level.MIN_ROOM_SIZE, room_size - 2 * level.MIN_PADDING);

    const offset_x = rand.intRangeAtMost(usize, level.MIN_PADDING, room_size - width - level.MIN_PADDING);
    const offset_y = rand.intRangeAtMost(usize, level.MIN_PADDING, room_size - height - level.MIN_PADDING);

    for ((start_y + offset_y)..(start_y + offset_y + height)) |y| {
        for ((start_x + offset_x)..(start_x + offset_x + width)) |x| {
            const idx = y * level.SIZE + x;
            tiles.items[idx] = get_floor(rand);
        }
    }

    return .{
        .start_x = start_x + offset_x,
        .start_y = start_y + offset_y,
        .width = width,
        .height = height,
        .doors = [_]Vec(usize){.{ .x = 0, .y = 0 }} ** 8,
        .nr_doors = 0,
    };
}

fn connect_rooms(rooms: []level.Room, tiles: []level.Tile, rand: std.Random) void {
    const MAX_ROOMS = level.GRID_SIZE * level.GRID_SIZE;

    // Indices of rooms in graph. Start with random room index.
    var in_graph: [MAX_ROOMS]usize = undefined;
    in_graph[0] = rand.uintLessThan(usize, MAX_ROOMS);

    // Number of rooms in graph.
    var nr_in_graph: usize = 1;

    var connections: [MAX_ROOMS][MAX_ROOMS]bool = undefined;
    for (connections, 0..) |_, i| {
        @memset(&connections[i], false);
    }

    // Buffer used to get neighbors in the future.
    var buffer: [MAX_ROOMS]usize = undefined;

    while (nr_in_graph < MAX_ROOMS) {
        // Pick random room in graph.
        const idx_1 = in_graph[rand.uintLessThan(usize, nr_in_graph)];

        // Pick random neighbor not in graph
        var neighbours = get_neighbours(idx_1, &buffer);

        // Remove neighbors already in graph
        var i: usize = 0;
        while (i < neighbours.len) {
            if (contains(usize, in_graph[0..nr_in_graph], neighbours[i])) {
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
        in_graph[nr_in_graph] = idx_2;
        nr_in_graph += 1;
        connections[idx_1][idx_2] = true;
        connections[idx_2][idx_1] = true;

        draw_tunnel(rooms, tiles, idx_1, idx_2, rand);
    }

    // Add some random connections
    const nr_extra_cons = rand.intRangeAtMost(usize, 1, level.MAX_EXTRA_TUNNELS);
    var added_cons: usize = 0;
    while (added_cons < nr_extra_cons) {
        // Pick random room
        const idx_1 = in_graph[rand.uintLessThan(usize, nr_in_graph)];

        // Get neighbors
        var neighbors = get_neighbours(idx_1, &buffer);

        // Remove neighbors already connected.
        var i: usize = 0;
        while (i < neighbors.len) {
            if (connections[idx_1][neighbors[i]]) {
                neighbors[i] = neighbors[neighbors.len - 1];
                neighbors = neighbors[0 .. neighbors.len - 1];
            } else {
                i += 1;
            }
        }

        if (neighbors.len == 0) {
            continue;
        }

        const idx_2 = neighbors[rand.uintLessThan(usize, neighbors.len)];
        connections[idx_1][idx_2] = true;
        connections[idx_2][idx_1] = true;
        added_cons += 1;

        draw_tunnel(rooms, tiles, idx_1, idx_2, rand);
    }
}

fn draw_tunnel(rooms: []level.Room, tiles: []level.Tile, idx_1: usize, idx_2: usize, rand: std.Random) void {
    const start_idx = @min(idx_1, idx_2);
    const end_idx = @max(idx_1, idx_2);
    var start = &rooms[start_idx];
    var end = &rooms[end_idx];

    var start_pos: Vec(usize) = undefined;
    var end_pos: Vec(usize) = undefined;
    var move_step: Vec(usize) = undefined;
    var turn_step: Vec(i32) = undefined;
    var distance: usize = undefined;
    var turn_distance: usize = undefined;

    // Horizontal
    if (end_idx - start_idx == 1) {
        const start_x = start.start_x + start.width;
        const end_x = end.start_x - 1;
        distance = end_x - start_x + 1;

        const start_y = start.start_y + rand.uintLessThan(usize, start.height);
        const end_y = end.start_y + rand.uintLessThan(usize, end.height);

        var turn_y: i32 = undefined;
        if (start_y < end_y) {
            turn_y = 1;
            turn_distance = end_y - start_y;
        } else {
            turn_y = -1;
            turn_distance = start_y - end_y;
        }

        start_pos = .{ .x = start_x, .y = start_y };
        end_pos = .{ .x = end_x, .y = end_y };
        move_step = .{ .x = 1, .y = 0 };
        turn_step = .{ .x = 0, .y = turn_y };
    }
    // Vertical
    else {
        const start_y = start.start_y + start.height;
        const end_y = end.start_y - 1;
        distance = end_y - start_y + 1;

        const start_x = start.start_x + rand.uintLessThan(usize, start.width);
        const end_x = end.start_x + rand.uintLessThan(usize, end.width);

        var turn_x: i32 = undefined;
        if (start_x < end_x) {
            turn_x = 1;
            turn_distance = end_x - start_x;
        } else {
            turn_x = -1;
            turn_distance = start_x - end_x;
        }

        start_pos = .{ .x = start_x, .y = start_y };
        end_pos = .{ .x = end_x, .y = end_y };
        move_step = .{ .x = 0, .y = 1 };
        turn_step = .{ .x = turn_x, .y = 0 };
    }

    // Add doors
    start.doors[start.nr_doors] = start_pos;
    start.doors[start.nr_doors + 1] = end_pos;
    start.nr_doors += 2;

    end.doors[end.nr_doors] = start_pos;
    end.doors[end.nr_doors + 1] = end_pos;
    end.nr_doors += 2;

    // Add hallway
    const turn_point = rand.intRangeLessThan(usize, 1, distance - 1);
    var pos = start_pos;
    for (0..distance) |d| {
        if (d == turn_point) {
            for (0..turn_distance) |_| {
                tiles[pos.y * level.SIZE + pos.x] = get_floor(rand);
                pos.x = @intCast(@as(i32, @intCast(pos.x)) + turn_step.x);
                pos.y = @intCast(@as(i32, @intCast(pos.y)) + turn_step.y);
            }
        }

        tiles[pos.y * level.SIZE + pos.x] = get_floor(rand);
        pos.x += move_step.x;
        pos.y += move_step.y;
    }

    // Add door tiles
    tiles[start_pos.y * level.SIZE + start_pos.x] = .{ .door = &assets.door };
    tiles[end_pos.y * level.SIZE + end_pos.x] = .{ .door = &assets.door };
}

fn get_neighbours(idx: usize, buffer: []usize) []usize {
    var i: usize = 0;

    // Down
    if (idx >= level.GRID_SIZE) {
        buffer[i] = idx - level.GRID_SIZE;
        i += 1;
    }

    // Up
    if (idx + level.GRID_SIZE < level.GRID_SIZE * level.GRID_SIZE) {
        buffer[i] = idx + level.GRID_SIZE;
        i += 1;
    }

    // Left
    if (idx % level.GRID_SIZE != 0) {
        buffer[i] = idx - 1;
        i += 1;
    }

    // Right
    if (idx % level.GRID_SIZE != level.GRID_SIZE - 1) {
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

fn get_floor(rand: std.Random) level.Tile {
    const rdx = rand.uintLessThan(u8, 20);

    const floor_img = switch (rdx) {
        0 => &assets.floor2,
        1 => &assets.floor3,
        2 => &assets.floor4,
        3 => &assets.floor5,
        else => &assets.floor1,
    };

    var ceil_img = &assets.ceiling1;
    if (rdx < 3) {
        ceil_img = &assets.ceiling2;
    }

    return .{ .empty = .{
        .floor = floor_img,
        .ceiling = ceil_img,
    } };
}
