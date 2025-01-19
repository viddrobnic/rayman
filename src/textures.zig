const std = @import("std");
const Color = @import("color.zig");

pub const Texture = struct {
    width: usize,
    height: usize,
    pixels: []Color,

    const Self = @This();

    pub fn get_pixel(self: *const Self, x: f32, y: f32) Color {
        var x_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.width)) * x);
        var y_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.height)) * y);

        if (x_idx >= self.width) {
            x_idx = self.width - 1;
        }
        if (y_idx >= self.height) {
            y_idx = self.height - 1;
        }

        const idx = y_idx * self.width + x_idx;
        return self.pixels[idx];
    }
};

fn texture_from_color(allocator: std.mem.Allocator, color: Color) !Texture {
    const pixels = try allocator.alloc(Color, 1);
    pixels[0] = color;

    return .{
        .width = 1,
        .height = 1,
        .pixels = pixels,
    };
}

pub const TextureManager = struct {
    // Available textures
    red: Texture,
    floor1: Texture,
    floor2: Texture,

    // Allocator
    arena: std.heap.ArenaAllocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        var arena = std.heap.ArenaAllocator.init(allocator);
        const arena_alloc = arena.allocator();

        return .{
            .red = try texture_from_color(arena_alloc, Color.new(255, 0, 0)),
            .floor1 = try texture_from_color(arena_alloc, Color.new(0x44, 0x44, 0x44)),
            .floor2 = try texture_from_color(arena_alloc, Color.new(0x66, 0x66, 0x66)),

            .arena = arena,
        };
    }

    pub fn deinit(self: *const Self) void {
        self.arena.deinit();
    }
};
