const image = @import("image.zig");

const block_data = @embedFile("asset_block");

red: image.Image,
floor1: image.Image,
floor2: image.Image,
block: image.Image,

const Self = @This();

pub fn init() !Self {
    return .{
        .red = image.from_color(255, 0, 0),
        .floor1 = image.from_color(0x44, 0x44, 0x44),
        .floor2 = image.from_color(0x66, 0x66, 0x66),
        .block = try image.from_data(block_data),
    };
}
