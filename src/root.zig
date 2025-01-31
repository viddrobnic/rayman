const std = @import("std");
const screen = @import("screen.zig");

const Game = @import("game/game.zig");
const render = @import("game/render.zig");
const assets = @import("assets/assets.zig");

var game: Game = undefined;

// -------------------------
// Functions provided by js.
// -------------------------
pub extern fn log_int(i32) void;

// ---------------------------
// Functions exported to wasm
// ---------------------------
pub export fn init(seed: u32) void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .safety = false,
    }){};
    const allocator = gpa.allocator();

    assets.init() catch {
        @panic("Failed to initialize assets");
    };

    game = Game.init(allocator, seed) catch {
        @panic("Failed to initialize game");
    };
}

pub export fn draw() void {
    render.render(&game);
}

pub export fn set_size(width: usize, height: usize) void {
    screen.width = width;
    screen.height = height;
}

pub export fn update(dt: f32, w_pressed: bool, a_pressed: bool, s_pressed: bool, d_pressed: bool) void {
    game.update(dt, w_pressed, a_pressed, s_pressed, d_pressed);
}

test "render once" {
    init(2);
    draw();
}
