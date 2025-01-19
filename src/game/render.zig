const screen = @import("../screen.zig");
const Color = @import("../color.zig");
const Game = @import("game.zig");

const vec_from_polar = @import("../vec.zig").from_polar;
const Vec = @import("../vec.zig").Vec(f32);

const CAMERA_WIDTH = 1.0;
const CAMERA_HEIGHT = 1.0;

const Camera = struct {
    direction: Vec,
    plane: Vec,
};

pub fn render(game: *const Game) void {
    const camera_direction = vec_from_polar(game.player_rot);
    const camera = Camera{
        .direction = camera_direction,
        .plane = camera_direction.rotate_90(),
    };

    render_floor_ceil(game, camera);
}

fn render_floor_ceil(game: *const Game, camera: Camera) void {
    var y: usize = 0;
    while (y < screen.height / 2) : (y += screen.SCALE) {
        // camera factor between 1.0 and 0 (0 middle of screen, 1 at the top)
        // player_pos + t * (camera_dir + camera_plane + (0, 0, camera_factor)) = (0, 0, CAMERA_HEIGHT)
        // because all other vectors are 2d:
        // t * camera_factor = CAMERA_HEIGHT
        // t = CAMERA_HEIGHT / camera_factor
        const camera_factor = 1.0 - 2.0 * (@as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(screen.height)));
        const t = CAMERA_HEIGHT / camera_factor;

        // Now we can calculate the most left and right vector for the current row.
        // Vectors represent position on map.
        const extreme = camera.plane.scalar_mul(CAMERA_WIDTH);
        const left = game.player_pos.add(&camera.direction.add(&extreme).scalar_mul(t));
        const right = game.player_pos.add(&camera.direction.sub(&extreme).scalar_mul(t));

        const diff = right.sub(&left);

        var x: usize = 0;
        while (x < screen.width) : (x += screen.SCALE) {
            // Get position on the map for current pixel
            const step = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(screen.width));
            const position = left.add(&diff.scalar_mul(step));

            // Get tile on the map
            const tile = game.level.get_tile(@intFromFloat(position.x), @intFromFloat(position.y));
            if (tile == null) {
                continue;
            }

            // Get floor and ceiling color
            var floor_color: Color = undefined;
            var ceil_color: Color = undefined;
            switch (tile.?) {
                .empty => |empty| {
                    // We can use truncate, because position is always >=0
                    const text_x = position.x - @trunc(position.x);
                    const text_y = position.y - @trunc(position.y);

                    floor_color = empty.floor.get_pixel(text_x, text_y);
                    ceil_color = empty.ceiling.get_pixel(text_x, text_y);
                },
                .wall => {
                    floor_color = Color.new(0, 0, 0);
                    ceil_color = Color.new(0, 0, 0);
                },
            }

            // Draw the pixels
            for (0..screen.SCALE) |dy| {
                for (0..screen.SCALE) |dx| {
                    // Draw floor
                    screen.draw_pixel(x + dx, screen.height - (y + dy) - 1, floor_color);

                    // Draw ceiling
                    screen.draw_pixel(x + dx, y + dy, ceil_color);
                }
            }
        }
    }
}
