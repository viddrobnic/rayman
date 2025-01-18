const screen = @import("../screen.zig");
const Game = @import("game.zig");

const Color = @import("../color.zig");

pub fn render(_: *const Game) void {
    const color = Color.new(255, 0, 0);

    for (0..screen.height) |y| {
        for (0..screen.width) |x| {
            screen.draw_pixel(x, y, color);
        }
    }
}
