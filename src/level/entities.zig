const std = @import("std");

const assets = @import("../assets/assets.zig");
const level = @import("level.zig");
const entity = @import("../entity/entity.zig");
const Vec = @import("../vec.zig").Vec;

pub fn generate_entities(room: *level.Room, entities: *std.ArrayList(entity.Entity), rand: std.Random) !void {
    const nr_gold = rand.intRangeLessThan(u8, 1, 5);
    for (0..nr_gold) |i| {
        const position = Vec(f32){
            .x = @as(f32, @floatFromInt(rand.intRangeLessThan(u32, room.start_x, room.start_x + room.width))) + 0.5,
            .y = @as(f32, @floatFromInt(rand.intRangeLessThan(u32, room.start_y, room.start_y + room.height))) + 0.5,
        };

        const ent = entity.Entity{
            .position = position,
            .size = Vec(f32){ .x = 0.2, .y = 0.2 },
            .floor_offset = 0.2,
            .offset_time = @floatFromInt(i),
            .texture = &assets.gold,
            .room = room,
        };
        try entities.append(ent);
    }
}
