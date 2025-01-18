const std = @import("std");

const textures = @import("textures.zig");
const levels = @import("level.zig");
const Vec = @import("vec.zig").Vec;

const Self = @This();

player_pos: Vec(f32),
player_rot: f32,

level: levels.Level,
texture_manager: textures.TextureManager,

pub fn init(allocator: std.mem.Allocator) !Self {
    const texture_manager = try textures.TextureManager.init(allocator);

    return .{
        .player_pos = Vec(f32){ .x = 7.5, .y = 5.0 },
        .player_rot = 0.0,

        .level = try levels.generate(allocator, &texture_manager, 10, 10),
        .texture_manager = texture_manager,
    };
}
