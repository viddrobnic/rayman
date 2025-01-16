const std = @import("std");
const render = @import("render.zig");
const screen = @import("screen.zig");

var time: f32 = 0.0;

// Functions provided by js.
pub extern fn log_int(i32) void;

// Functions exported to wasm
pub export fn init() void {}

pub export fn draw() void {
    render.render(time);
}

pub export fn set_size(width: usize, height: usize) void {
    screen.width = width;
    screen.height = height;
}

pub export fn update(dt: f32, _: bool, _: bool, _: bool, _: bool) void {
    time += dt;
}
