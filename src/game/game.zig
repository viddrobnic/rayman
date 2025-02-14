const std = @import("std");

const levels = @import("../level/level.zig");
const entity = @import("../entity/entity.zig");

const vec_from_polar = @import("../vec.zig").from_polar;
const Vec = @import("../vec.zig").Vec(f32);

const SPEED = 1.8;
const ROTATION_SPEED = 1.8;

const PLAYER_BOUND_MARGIN = 0.1;

player_pos: Vec,
player_rot: f32,

coins: u16 = 0,
health: u8 = 100,

level: levels.Level,
entities: std.ArrayList(entity.Entity),

time: f32 = 0.0,

const Self = @This();

pub fn init(allocator: std.mem.Allocator, seed: u64) !Self {
    var entities = std.ArrayList(entity.Entity).init(allocator);
    const level = try levels.generate(allocator, seed, &entities);

    // TODO: Choose starting point better
    const player_x = level.rooms.items[0].start_x + 1;
    const player_y = level.rooms.items[0].start_y + 1;

    return .{
        .player_pos = Vec{ .x = @floatFromInt(player_x), .y = @floatFromInt(player_y) },
        .player_rot = 0.0,

        .level = level,
        .entities = entities,
    };
}

pub fn update(
    self: *Self,
    dt: f32,
    w_pressed: bool,
    a_pressed: bool,
    s_pressed: bool,
    d_pressed: bool,
    _: bool,
) void {
    self.time += dt;

    // If player is dead, do nothing
    if (self.health <= 0) {
        return;
    }

    // Rotate the player
    if (a_pressed) {
        self.player_rot += ROTATION_SPEED * dt;
    } else if (d_pressed) {
        self.player_rot -= ROTATION_SPEED * dt;
    }
    self.player_rot = @mod(self.player_rot, 2.0 * std.math.pi);

    // Move the player
    self.move_player(dt, w_pressed, s_pressed);

    // Update entities.
    var i: usize = 0;
    while (i < self.entities.items.len) {
        const ent = &self.entities.items[i];
        const should_delete = ent.update_fn(ent, self);
        if (should_delete) {
            self.entities.items[i] = self.entities.items[self.entities.items.len - 1];
            _ = self.entities.pop();
        } else {
            i += 1;
        }
    }
}

pub fn clear_room(self: *Self) void {
    self.level.clear_room(self.player_pos.x, self.player_pos.y);
}

fn move_player(
    self: *Self,
    dt: f32,
    w_pressed: bool,
    s_pressed: bool,
) void {
    const direction = vec_from_polar(self.player_rot);
    var move_vec: ?Vec = null;
    if (w_pressed) {
        move_vec = direction.scalar_mul(SPEED * dt);
    } else if (s_pressed) {
        move_vec = direction.scalar_mul(-SPEED * dt);
    }

    if (move_vec == null) {
        return;
    }

    const move_direction: Vec = .{
        .x = std.math.sign(move_vec.?.x),
        .y = std.math.sign(move_vec.?.y),
    };
    var new_pos = self.player_pos;

    // Move x
    var tile = self.level.get_tile(
        @intFromFloat(new_pos.x + move_vec.?.x + move_direction.x * PLAYER_BOUND_MARGIN),
        @intFromFloat(new_pos.y),
    );
    if (tile) |t| {
        if (t == .empty) {
            new_pos.x += move_vec.?.x;
        }
    }

    // Move y
    tile = self.level.get_tile(
        @intFromFloat(new_pos.x),
        @intFromFloat(new_pos.y + move_vec.?.y + move_direction.y * PLAYER_BOUND_MARGIN),
    );
    if (tile) |t| {
        if (t == .empty) {
            new_pos.y += move_vec.?.y;
        }
    }

    self.player_pos = new_pos;
}
