const level = @import("../level/level.zig");
const image = @import("../assets/image.zig");
const assets = @import("../assets/assets.zig");

const Vec = @import("../vec.zig").Vec;
const Game = @import("../game/game.zig");
const ItemData = @import("items.zig").Data;
const MonsterData = @import("monsters.zig").Data;

pub const Entity = struct {
    position: Vec(f32),
    size: Vec(f32),
    floor_offset: f32,
    texture: *const image.Image,

    kind: Kind,
    data: EntityData,

    // Function called for every update. Return true if entity should be removed
    // from the pool, false otherwise.
    update_fn: *const fn (self: *@This(), game: *Game) bool,

    // Distance from camera used for rendering
    distance: f32 = undefined,
};

const Kind = enum {
    item,
    monster,
};

const EntityData = union(Kind) {
    item: ItemData,
    monster: MonsterData,
};
