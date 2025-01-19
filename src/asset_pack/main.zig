const std = @import("std");

const c = @cImport({
    @cInclude("stb_image.h");
});

const usage =
    \\Usage: ./asset_pack <input_path> <output_path>
    \\
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        try std.io.getStdOut().writeAll(usage);
        return std.process.exit(1);
    }

    var input_file = std.fs.cwd().openFile(args[1], .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ args[1], @errorName(err) });
    };
    defer input_file.close();

    var output_file = std.fs.cwd().createFile(args[2], .{}) catch |err| {
        fatal("unable to open '{s}': {s}", .{ args[2], @errorName(err) });
    };
    defer output_file.close();

    var width: u32 = undefined;
    var height: u32 = undefined;
    const channels = 4;

    const pixels = c.stbi_load(args[1], @ptrCast(&width), @ptrCast(&height), null, channels);
    const size = width * height * channels;

    // write width
    var buffer: [4]u8 = undefined;
    std.mem.writeInt(u32, &buffer, width, .big);
    try output_file.writeAll(&buffer);

    // write height
    std.mem.writeInt(u32, &buffer, height, .big);
    try output_file.writeAll(&buffer);

    // write pixels
    try output_file.writeAll(pixels[0..size]);

    return std.process.cleanExit();
}

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}
