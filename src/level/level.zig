const std = @import("std");
const assets = @import("../assets/assets.zig");
const Image = @import("../assets/image.zig").Image;
const Vec = @import("../vec.zig").Vec;

const _clear_room = @import("clear_room.zig").clear_room;

pub const generate = @import("generate.zig").generate;

pub const GRID_SIZE = 3;
pub const SIZE = 60;
pub const MIN_ROOM_SIZE = 5;
pub const MIN_PADDING = 2;
pub const MAX_EXTRA_TUNNELS = 3;

pub const Tile = union(enum) {
    wall: *const Image,
    empty: struct {
        floor: *const Image,
        ceiling: *const Image,
    },
    door: *const Image,
};

pub const Room = struct {
    start_x: usize,
    start_y: usize,
    width: usize,
    height: usize,

    nr_monsters: u8 = 0,
    cleared: bool = false,

    // Doors that have to be removed when the room is cleared.
    // These are coordinates to doors in this room (4 of them) and
    // coordinates of rooms on the other side of the halls (4 of them).
    doors: [8]Vec(usize),
    nr_doors: u8,
};

pub const Level = struct {
    width: usize,
    height: usize,

    tiles: std.ArrayList(Tile),

    rooms: std.ArrayList(Room),

    const Self = @This();

    pub fn get_tile(self: *const Self, x: usize, y: usize) ?Tile {
        if (x >= self.width or y >= self.height) {
            return null;
        }

        return self.tiles.items[y * self.width + x];
    }

    pub fn clear_room(self: *Self, x: f32, y: f32) void {
        const x_u: usize = @intFromFloat(x);
        const y_u: usize = @intFromFloat(y);

        const room_size = SIZE / GRID_SIZE;
        const room_x = x_u / room_size;
        const room_y = y_u / room_size;

        const room = &self.rooms.items[room_y * GRID_SIZE + room_x];
        if (x_u < room.start_x or x_u >= room.start_x + room.width) {
            return;
        }
        if (y_u < room.start_y or y_u >= room.start_y + room.height) {
            return;
        }

        _clear_room(room, self.tiles.items);
    }
};
