const image = @import("image.zig");

const block_data = @embedFile("asset_block");

// Collection of shared assets.
pub var red: image.Image = undefined;
pub var floor1: image.Image = undefined;
pub var floor2: image.Image = undefined;
pub var block: image.Image = undefined;

pub fn init() !void {
    red = image.from_color(255, 0, 0);
    floor1 = image.from_color(0x44, 0x44, 0x44);
    floor2 = image.from_color(0x66, 0x66, 0x66);
    block = try image.from_data(block_data);
}
