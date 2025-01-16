const screen = @import("screen.zig");
const Color = @import("color.zig");

pub fn render(time: f32) void {
    const color_comp: u8 = @intCast(@as(i16, @intFromFloat(@sin(time) * 127.0)) + 127);
    const color = Color.new(color_comp, color_comp, color_comp);

    for (0..screen.height) |y| {
        for (0..screen.width) |x| {
            screen.draw_pixel(x, y, color);
        }
    }
}
