const std = @import("std");

const Color = @import("../color.zig");

pub const ImageData = struct {
    width: usize,
    height: usize,
    pixels: []const u8,

    pub fn get_pixel(self: *const @This(), x: f32, y: f32) Color {
        var x_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.width)) * x);
        var y_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.height)) * y);

        if (x_idx >= self.width) {
            x_idx = self.width - 1;
        }
        if (y_idx >= self.height) {
            y_idx = self.height - 1;
        }

        const idx = (y_idx * self.width + x_idx) * 4;
        return Color{
            .red = self.pixels[idx],
            .green = self.pixels[idx + 1],
            .blue = self.pixels[idx + 2],
            .alpha = self.pixels[idx + 3],
        };
    }
};

pub const Image = union(enum) {
    color: Color,
    image_data: ImageData,

    pub fn get_pixel(self: *const @This(), x: f32, y: f32) Color {
        return switch (self.*) {
            .color => |c| c,
            .image_data => |*data| data.get_pixel(x, y),
        };
    }
};

pub fn from_data(data: []const u8) !Image {
    if (data.len < 8) {
        return error.InvalidLength;
    }

    const width = std.mem.readInt(u32, data[0..4], .big);
    const height = std.mem.readInt(u32, data[4..8], .big);

    const expected_len = width * height * 4 + 8;
    if (data.len < expected_len) {
        return error.InvalidLength;
    }

    const image_data = ImageData{
        .width = width,
        .height = height,
        .pixels = data[8..],
    };

    return .{ .image_data = image_data };
}

pub fn from_color(red: u8, green: u8, blue: u8) Image {
    const color = Color.new(red, green, blue);
    return .{ .color = color };
}
