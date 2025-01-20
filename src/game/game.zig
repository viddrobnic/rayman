const std = @import("std");

const levels = @import("../level.zig");
const Assets = @import("../assets/assets.zig");

const vec_from_polar = @import("../vec.zig").from_polar;
const Vec = @import("../vec.zig").Vec(f32);

const SPEED = 1.8;
const ROTATION_SPEED = 1.8;

const PLAYER_BOUND_MARGIN = 0.1;

player_pos: Vec,
player_rot: f32,

level: levels.Level,
assets: Assets,

const Self = @This();

pub fn init(allocator: std.mem.Allocator) !Self {
    const assets = try Assets.init();

    return .{
        .player_pos = Vec{ .x = 7.5, .y = 5.0 },
        .player_rot = 0.0,

        .level = try levels.generate(allocator, &assets, 10, 10),
        .assets = assets,
    };
}

pub fn update(self: *Self, dt: f32, w_pressed: bool, a_pressed: bool, s_pressed: bool, d_pressed: bool) void {
    // Rotate the player
    if (a_pressed) {
        self.player_rot += ROTATION_SPEED * dt;
    } else if (d_pressed) {
        self.player_rot -= ROTATION_SPEED * dt;
    }
    self.player_rot = @mod(self.player_rot, 2.0 * std.math.pi);

    // Move the player
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
