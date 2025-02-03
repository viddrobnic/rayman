const level = @import("level.zig");
const assets = @import("../assets/assets.zig");

pub fn clear_room(room: *level.Room, tiles: []level.Tile) void {
    if (room.cleared) {
        return;
    }

    for (room.doors[0..room.nr_doors]) |door| {
        const idx = door.y * level.SIZE + door.x;
        tiles[idx] = .{ .empty = .{
            .floor = &assets.floor1,
            .ceiling = &assets.ceiling1,
        } };
    }

    room.cleared = true;
}
