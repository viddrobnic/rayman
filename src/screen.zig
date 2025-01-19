const Color = @import("color.zig");

pub const MAX_WIDTH = 1280;
pub const MAX_HEIGHT = 720;
pub const SCALE = 2;

pub var width: usize = MAX_WIDTH;
pub var height: usize = MAX_HEIGHT;
pub var screen: [MAX_WIDTH * MAX_HEIGHT * 4]u8 = undefined;

pub export fn get_screen() [*]u8 {
    return &screen;
}

pub fn draw_pixel(x: usize, y: usize, color: Color) void {
    const idx: usize = (y * width + x) * 4;
    screen[idx] = color.red;
    screen[idx + 1] = color.green;
    screen[idx + 2] = color.blue;
    screen[idx + 3] = color.alpha;
}
