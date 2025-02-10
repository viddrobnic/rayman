const image = @import("image.zig");

const block_data = @embedFile("asset_block");
const tiles_data = @embedFile("tiles");
const font_data = @embedFile("font");
const coin_data = @embedFile("coin");
const key_data = @embedFile("key");
const bat_data = @embedFile("bat");

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

pub var gold: image.Image = undefined;
pub var key: image.Image = undefined;

pub var bat1: image.Image = undefined;
pub var bat2: image.Image = undefined;
pub var bat3: image.Image = undefined;
pub var bat4: image.Image = undefined;

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

    gold = try image.from_data(coin_data);
    key = try image.from_data(key_data);

    bat1 = try image.from_asset_pack(bat_data, 32, 32, 0, 0);
    bat2 = try image.from_asset_pack(bat_data, 32, 32, 1, 0);
    bat3 = try image.from_asset_pack(bat_data, 32, 32, 2, 0);
    bat4 = try image.from_asset_pack(bat_data, 32, 32, 3, 0);
}
