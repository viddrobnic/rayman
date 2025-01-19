const std = @import("std");

const block_data = @embedFile("asset_block");

block: Asset,

pub const Asset = struct {
    width: u32,
    height: u32,
    pixels: []const u8,

    pub fn init(data: []const u8) @This() {
        const width = std.mem.readInt(u32, data[0..4], .big);
        const height = std.mem.readInt(u32, data[4..8], .big);

        return .{
            .width = width,
            .height = height,
            .pixels = data[8..],
        };
    }
};

pub fn init() @This() {
    return .{
        .block = Asset.init(block_data),
    };
}
