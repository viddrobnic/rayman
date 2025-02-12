const assets = @import("../assets/assets.zig");
const level = @import("../level/level.zig");

const Entity = @import("entity.zig").Entity;
const Vec = @import("../vec.zig").Vec;
const Game = @import("../game/game.zig");

pub const Data = struct {
    // Random time offset. Used so that animations
    // are not synchronized.
    offset_time: f32 = 0.0,
    room: *level.Room,

    prev_time: f32 = 0.0,
};

fn update_bat(ent: *Entity, game: *Game) bool {
    // Set texture
    const time: usize = @intFromFloat(game.time * 7.0 + ent.data.monster.offset_time);
    switch (time % 4) {
        0 => ent.texture = &assets.bat1,
        1 => ent.texture = &assets.bat2,
        2 => ent.texture = &assets.bat3,
        3 => ent.texture = &assets.bat4,
        else => unreachable,
    }

    // Check if we have to move
    const player_pos = game.player_pos;
    const room = ent.data.monster.room;
    if (player_pos.x < @as(f32, @floatFromInt(room.start_x)) or player_pos.x >= @as(f32, @floatFromInt(room.start_x + room.width))) {
        return false;
    }
    if (player_pos.y < @as(f32, @floatFromInt(room.start_y)) or player_pos.y >= @as(f32, @floatFromInt(room.start_y + room.height))) {
        return false;
    }

    const dt = game.time - ent.data.monster.prev_time;
    ent.data.monster.prev_time = game.time;

    const dir = player_pos.sub(&ent.position).normalize();
    const diff = dir.scalar_mul(dt * 1.0); // 1.0 is speed
    const new_pos = ent.position.add(&diff);

    for (game.entities.items) |e| {
        if (e.kind != .monster) {
            continue;
        }

        if (e.position.x == ent.position.x and e.position.y == ent.position.y) {
            continue;
        }

        const dist = new_pos.sub(&e.position).length_squared();
        if (dist < 0.25) {
            return false;
        }
    }

    ent.position = new_pos;
    return false;
}

pub fn new_bat(position: Vec(f32), offset_time: f32, room: *level.Room) Entity {
    return .{
        .position = position,
        .size = .{ .x = 0.7, .y = 0.7 },
        .floor_offset = 0.6,
        .texture = &assets.bat1,
        .kind = .monster,
        .data = .{ .monster = .{
            .offset_time = offset_time,
            .room = room,
        } },
        .update_fn = &update_bat,
    };
}
