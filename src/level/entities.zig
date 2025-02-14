const std = @import("std");

const assets = @import("../assets/assets.zig");
const level = @import("level.zig");
const items = @import("../entity/items.zig");
const monsters = @import("../entity/monsters.zig");
const entity = @import("../entity/entity.zig");

const Vec = @import("../vec.zig").Vec;

pub fn generate_entities(room: *level.Room, entities: *std.ArrayList(entity.Entity), rand: std.Random) !void {
    // Generate gold
    const nr_gold = rand.intRangeLessThan(u8, 1, 5);
    for (0..nr_gold) |i| {
        const position = rand_position(room, rand);
        const ent = items.new(.coin, position, @floatFromInt(i));
        try entities.append(ent);
    }

    // Generate monsters
    const nr_monsters = rand.intRangeLessThan(u8, 3, 10);
    room.nr_monsters = nr_monsters;
    for (0..nr_monsters) |i| {
        const position = rand_position(room, rand);
        const ent = monsters.new_bat(position, @floatFromInt(i), room);
        try entities.append(ent);
    }
}

fn rand_position(room: *const level.Room, rand: std.Random) Vec(f32) {
    return .{
        .x = @as(f32, @floatFromInt(rand.intRangeLessThan(u32, room.start_x, room.start_x + room.width))) + 0.5,
        .y = @as(f32, @floatFromInt(rand.intRangeLessThan(u32, room.start_y, room.start_y + room.height))) + 0.5,
    };
}
