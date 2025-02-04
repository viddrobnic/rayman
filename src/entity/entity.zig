const level = @import("../level/level.zig");
const image = @import("../assets/image.zig");
const Vec = @import("../vec.zig").Vec;
const Game = @import("../game/game.zig");

pub const Entity = struct {
    position: Vec(f32),
    size: Vec(f32),
    floor_offset: f32,
    texture: *const image.Image,

    // Random time offset. Used so that animations
    // are not synchronized between all items.
    offset_time: f32 = 0.0,

    room: ?*level.Room = null,

    // Distance from camera used for rendering
    distance: f32 = undefined,

    const Self = @This();

    pub fn update(self: *Self, game: *Game) void {
        const offset = @sin(game.time * 4.0 + self.offset_time);
        self.floor_offset = (offset + 1.0) * self.size.y / 4.0 + self.size.y;
    }
};
