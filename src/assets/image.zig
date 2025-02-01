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

pub const AssetPack = struct {
    width: usize,
    height: usize,

    tile_width: usize,
    tile_height: usize,
    offset_x: usize,
    offset_y: usize,

    pixels: []const u8,

    pub fn get_pixel(self: *const @This(), x: f32, y: f32) Color {
        var x_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.tile_width)) * x);
        var y_idx: usize = @intFromFloat(@as(f32, @floatFromInt(self.tile_height)) * y);

        if (x_idx >= self.tile_width) {
            x_idx = self.tile_width - 1;
        }
        if (y_idx >= self.tile_height) {
            y_idx = self.tile_height - 1;
        }

        const idx = ((self.offset_y + y_idx) * self.width + self.offset_x + x_idx) * 4;
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
    asset_pack: AssetPack,

    pub fn get_pixel(self: *const @This(), x: f32, y: f32) Color {
        return switch (self.*) {
            .color => |c| c,
            .image_data => |*data| data.get_pixel(x, y),
            .asset_pack => |*pack| pack.get_pixel(x, y),
        };
    }
};

const Size = struct {
    width: usize,
    height: usize,
};

fn read_size(data: []const u8) !Size {
    if (data.len < 8) {
        return error.InvalidLength;
    }

    const width = std.mem.readInt(u32, data[0..4], .big);
    const height = std.mem.readInt(u32, data[4..8], .big);

    return .{
        .width = width,
        .height = height,
    };
}

pub fn from_data(data: []const u8) !Image {
    const size = try read_size(data);

    const expected_len = size.width * size.height * 4 + 8;
    if (data.len < expected_len) {
        return error.InvalidLength;
    }

    const image_data = ImageData{
        .width = size.width,
        .height = size.height,
        .pixels = data[8..],
    };

    return .{ .image_data = image_data };
}

pub fn from_asset_pack(
    data: []const u8,
    tile_width: usize,
    tile_height: usize,
    tile_x: usize,
    tile_y: usize,
) !Image {
    const size = try read_size(data);

    if (size.width % tile_width != 0) {
        return error.InvalidTileWidth;
    }
    if (size.height % tile_height != 0) {
        return error.InvalidTileHeight;
    }

    const offset_x = tile_width * tile_x;
    const offset_y = tile_height * tile_y;
    const asset_pack = AssetPack{
        .width = size.width,
        .height = size.height,
        .tile_width = tile_width,
        .tile_height = tile_height,
        .offset_x = offset_x,
        .offset_y = offset_y,
        .pixels = data[8..],
    };

    return .{ .asset_pack = asset_pack };
}

pub fn from_color(red: u8, green: u8, blue: u8) Image {
    const color = Color.new(red, green, blue);
    return .{ .color = color };
}
