const std = @import("std");

const assets = @import("../assets/assets.zig");
const level = @import("../level/level.zig");

const Entity = @import("entity.zig").Entity;
const Vec = @import("../vec.zig").Vec;
const Game = @import("../game/game.zig");

const MIN_DISTANCE = 0.4 * 0.4;
const ATTACK_DISTANCE = 0.5 * 0.5;
const ATTACK_COOLDOWN = 1.0;
// The amount of time monster travels away from the player
// after the monster was hit by the player.
const HIT_COOLDOWN = 0.5;

pub const Data = struct {
    // Random time offset. Used so that animations
    // are not synchronized.
    offset_time: f32 = 0.0,
    room: *level.Room,

    prev_time: f32 = 0.0,
    last_attack_time: f32 = -1.0,
    last_hit_time: f32 = -1.0,

    health: i8 = 10,
};

fn update_bat(ent: *Entity, game: *Game) bool {
    // Set texture
    const time: usize = @intFromFloat(game.time * 5.0 + ent.data.monster.offset_time);
    switch (time % 4) {
        0 => ent.texture = &assets.bat1,
        1 => ent.texture = &assets.bat2,
        2 => ent.texture = &assets.bat3,
        3 => ent.texture = &assets.bat4,
        else => unreachable,
    }

    // Set height
    const height_param = @as(f32, @floatFromInt(time)) / 4.0 * 2.0 * std.math.pi; // [0, 2pi]
    const height = (@sin(height_param) + 1.0) / 10.0;
    ent.floor_offset = 0.7 - height;

    // Update monster time
    const dt = game.time - ent.data.monster.prev_time;
    ent.data.monster.prev_time = game.time;

    // Check if we are in the same room as the player
    const player_pos = game.player_pos;
    const room = ent.data.monster.room;
    if (player_pos.x < @as(f32, @floatFromInt(room.start_x)) or player_pos.x >= @as(f32, @floatFromInt(room.start_x + room.width))) {
        return false;
    }
    if (player_pos.y < @as(f32, @floatFromInt(room.start_y)) or player_pos.y >= @as(f32, @floatFromInt(room.start_y + room.height))) {
        return false;
    }

    // Handle hitting player
    var dist = ent.position.sub(&game.player_pos).length_squared();
    const hit_time_diff = game.time - ent.data.monster.last_attack_time;
    if (dist < ATTACK_DISTANCE and hit_time_diff > ATTACK_COOLDOWN) {
        ent.data.monster.last_attack_time = game.time;
        game.health -= 5;
    }

    // Move the monster
    const dir = player_pos.sub(&ent.position).normalize();
    const diff = dir.scalar_mul(dt * 1.0); // 1.0 is speed

    if (game.time - ent.data.monster.last_hit_time < HIT_COOLDOWN) {
        ent.position = ent.position.sub(&diff);
        return false;
    }

    const new_pos = ent.position.add(&diff);

    dist = new_pos.sub(&game.player_pos).length_squared();
    if (dist < MIN_DISTANCE) {
        return false;
    }

    for (game.entities.items) |e| {
        if (e.kind != .monster) {
            continue;
        }

        if (e.position.x == ent.position.x and e.position.y == ent.position.y) {
            continue;
        }

        dist = new_pos.sub(&e.position).length_squared();
        if (dist < MIN_DISTANCE) {
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
