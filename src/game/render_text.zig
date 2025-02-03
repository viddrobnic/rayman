const std = @import("std");

const root = @import("../root.zig");

const screen = @import("../screen.zig");
const assets = @import("../assets/assets.zig");

const vec = @import("../vec.zig");
const Vec = vec.Vec;

const PER_ROW = 19;
const WIDTH = 30;
const HEIGHT = 30;

pub fn render_text(text: []const u8, position: Vec(f32), size: f32) void {
    const pixel_size = round_mul(size, screen.height);
    var pixel_pos = Vec(usize){
        .x = round_mul(position.x, screen.width),
        .y = round_mul(position.y, screen.height),
    };

    const fact = @as(f32, @floatFromInt(pixel_size)) / @as(f32, @floatFromInt(HEIGHT));
    const width: usize = round_mul(fact, WIDTH);

    for (text) |letter| {
        draw_letter(letter, pixel_pos, width, pixel_size);
        pixel_pos.x += width;
    }
}

fn draw_letter(letter: u8, position: Vec(usize), width: usize, height: usize) void {
    const idx: usize = letter - ' ';
    const y_idx = idx / PER_ROW;
    const x_idx = idx % PER_ROW;

    const start_x = x_idx * WIDTH;
    const start_y = y_idx * HEIGHT;

    for (0..height) |y| {
        const font_y = start_y + y * HEIGHT / height;
        for (0..width) |x| {
            const font_x = start_x + x * WIDTH / width;
            const c = assets.font.get_pixel_absolute(font_x, font_y);
            if (c.alpha == 255) {
                screen.draw_pixel(position.x + x, position.y + y, c);
            }
        }
    }
}

fn round_mul(a: f32, b: usize) usize {
    return @intFromFloat(a * @as(f32, @floatFromInt(b)));
}
