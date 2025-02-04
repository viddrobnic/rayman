const level = @import("../level/level.zig");
const image = @import("../assets/image.zig");
const Vec = @import("../vec.zig").Vec;

pub const Entity = struct {
    position: Vec(f32),
    size: Vec(f32),
    floor_offset: f32,
    texture: *const image.Image,

    room: ?*level.Room = null,

    // Distance from camera used for rendering
    distance: f32 = undefined,
};
