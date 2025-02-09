const assets = @import("../assets/assets.zig");

const Entity = @import("entity.zig").Entity;
const Vec = @import("../vec.zig").Vec;
const Game = @import("../game/game.zig");

pub const Data = struct {
    // Random time offset. Used so that animations
    // are not synchronized between all items.
    offset_time: f32 = 0.0,
};

pub const Type = enum {
    coin,
    key,
};

fn update_item(comptime item_type: Type) fn (*Entity, *Game) bool {
    return struct {
        fn update(ent: *Entity, game: *Game) bool {
            const offset = @sin(game.time * 4.0 + ent.data.item.offset_time);
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

pub fn new(
    comptime item_type: Type,
    position: Vec(f32),
    offset_time: f32,
) Entity {
    const texture = switch (item_type) {
        .coin => &assets.gold,
        .key => &assets.key,
    };

    return .{
        .position = position,
        .size = Vec(f32){ .x = 0.2, .y = 0.2 },
        .floor_offset = 0.2,
        .texture = texture,
        .data = .{ .item = .{
            .offset_time = offset_time,
        } },
        .update_fn = update_item(item_type),
    };
}
