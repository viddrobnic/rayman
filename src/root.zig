const std = @import("std");

const MAX_WIDTH = 1280;
const MAX_HEIGHT = 720;
const SCALE = 2;

pub var screen: [MAX_WIDTH * MAX_HEIGHT * 4]u8 = undefined;
var time: f32 = 0.0;

// Functions provided by js.
pub extern fn log_int(i32) void;

// Functions exported to wasm
pub export fn init() void {}

pub export fn get_screen() [*]u8 {
    return &screen;
}

pub export fn draw() void {
    const color: u8 = @intCast(@as(i16, @intFromFloat(@sin(time) * 127.0)) + 127);

    for (0..MAX_HEIGHT) |y| {
        for (0..MAX_WIDTH) |x| {
            const idx: usize = (y * MAX_WIDTH + x) * 4;
            screen[idx] = color;
            screen[idx + 1] = color;
            screen[idx + 2] = color;
            screen[idx + 3] = 255;
        }
    }
}

pub export fn set_size(_: usize, _: usize) void {}

pub export fn update(dt: f32, _: bool, _: bool, _: bool, _: bool) void {
    time += dt;
}
