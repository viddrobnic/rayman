const level = @import("../level/level.zig");
const image = @import("../assets/image.zig");
const assets = @import("../assets/assets.zig");
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

    // Function called for every update. Return true if entity should be removed
    // from the pool, false otherwise.
    update_fn: *const fn (self: *@This(), game: *Game) bool,

    // Distance from camera used for rendering
    distance: f32 = undefined,
};

pub const ItemType = enum {
    coin,
    key,
};

fn update_item(comptime item_type: ItemType) fn (*Entity, *Game) bool {
    return struct {
        fn update(ent: *Entity, game: *Game) bool {
            const offset = @sin(game.time * 4.0 + ent.offset_time);
            ent.floor_offset = (offset + 1.0) * ent.size.y / 4.0 + ent.size.y;

            const dist = ent.position.sub(&game.player_pos).length_squared();
            if (dist < 0.2) {
                switch (item_type) {
                    .coin => game.coins += 1,
                    .key => game.clear_room(),
                }
                return true;
            }

            return false;
        }
    }.update;
}

pub fn new_item(
    comptime item_type: ItemType,
    position: Vec(f32),
    offset_time: f32,
    room: ?*level.Room,
) Entity {
    const texture = switch (item_type) {
        .coin => &assets.gold,
        .key => &assets.door,
    };

    return .{
        .position = position,
        .size = Vec(f32){ .x = 0.2, .y = 0.2 },
        .floor_offset = 0.2,
        .offset_time = offset_time,
        .texture = texture,
        .room = room,
        .update_fn = update_item(item_type),
    };
}
