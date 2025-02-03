const image = @import("image.zig");

const block_data = @embedFile("asset_block");
const tiles_data = @embedFile("tiles");
const font_data = @embedFile("font");

// Collection of shared assets.
pub var floor1: image.Image = undefined;
pub var floor2: image.Image = undefined;
pub var floor3: image.Image = undefined;
pub var floor4: image.Image = undefined;
pub var floor5: image.Image = undefined;

pub var ceiling1: image.Image = undefined;
pub var ceiling2: image.Image = undefined;

pub var wall1: image.Image = undefined;
pub var wall2: image.Image = undefined;

pub var door: image.Image = undefined;

pub var font: image.Image = undefined;

pub fn init() !void {
    floor1 = try image.from_asset_pack(tiles_data, 16, 16, 0, 0);
    floor2 = try image.from_asset_pack(tiles_data, 16, 16, 1, 0);
    floor3 = try image.from_asset_pack(tiles_data, 16, 16, 2, 0);
    floor4 = try image.from_asset_pack(tiles_data, 16, 16, 3, 0);
    floor5 = try image.from_asset_pack(tiles_data, 16, 16, 4, 0);

    ceiling1 = try image.from_asset_pack(tiles_data, 16, 16, 0, 1);
    ceiling2 = try image.from_asset_pack(tiles_data, 16, 16, 1, 1);

    wall1 = try image.from_asset_pack(tiles_data, 16, 16, 2, 1);
    wall2 = try image.from_asset_pack(tiles_data, 16, 16, 3, 1);

    door = try image.from_asset_pack(tiles_data, 16, 16, 4, 1);

    font = try image.from_data(font_data);
}
