const std = @import("std");
const render = @import("render.zig");
const screen = @import("screen.zig");
const Textures = @import("textures.zig");

// Loaded textures
pub var textures: Textures = undefined;

// TODO: Remove once update is implemented correctly.
var time: f32 = 0.0;

// -------------------------
// Functions provided by js.
// -------------------------
pub extern fn log_int(i32) void;

// ---------------------------
// Functions exported to wasm
// ---------------------------
pub export fn init() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    textures = Textures.init(allocator) catch {
        @panic("Failed to initialize textures");
    };
}

pub export fn draw() void {
    render.render(time) catch {
        @panic("Failed to render screen");
    };
}

pub export fn set_size(width: usize, height: usize) void {
    screen.width = width;
    screen.height = height;
}

pub export fn update(dt: f32, _: bool, _: bool, _: bool, _: bool) void {
    time += dt;
}
