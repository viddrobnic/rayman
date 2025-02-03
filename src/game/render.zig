const std = @import("std");

const screen = @import("../screen.zig");
const image = @import("../assets/image.zig");
const Color = @import("../color.zig");
const Game = @import("game.zig");

const vec = @import("../vec.zig");
const Vec = vec.Vec;

const CAMERA_WIDTH = 1.0;
const CAMERA_HEIGHT = 1.0;

const Camera = struct {
    direction: Vec(f32),
    plane: Vec(f32),
};

pub fn render(game: *const Game) void {
    const camera_direction = vec.from_polar(game.player_rot);
    const camera = Camera{
        .direction = camera_direction,
        .plane = camera_direction.rotate_90(),
    };

    render_floor_ceil(game, camera);
    render_walls(game, camera);
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
            if (position.x < 0 or position.y < 0) {
                continue;
            }
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
                    const text_x = fraction(position.x);
                    const text_y = fraction(position.y);

                    floor_color = empty.floor.get_pixel(text_x, text_y);
                    ceil_color = empty.ceiling.get_pixel(text_x, text_y);
                },
                .wall, .door => {
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

const HitDirection = enum {
    horizontal,
    vertial,
};

fn render_walls(game: *const Game, camera: Camera) void {
    const player_idx = Vec(i32){
        .x = @intFromFloat(game.player_pos.x),
        .y = @intFromFloat(game.player_pos.y),
    };
    const player_rem = Vec(f32){
        .x = fraction(game.player_pos.x),
        .y = fraction(game.player_pos.y),
    };

    var x: usize = 0;
    while (x < screen.width) : (x += screen.SCALE) {
        const camera_factor = CAMERA_WIDTH * (1.0 - 2.0 * @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(screen.width)));
        const camera_point = camera.plane.scalar_mul(camera_factor);
        const ray = camera.direction.add(&camera_point);

        var tile_idx = player_idx; // Index of tile we are on.
        var tile_rem = player_rem; // Position inside the tile.

        const ray_direction = Vec(f32){
            .x = std.math.sign(ray.x),
            .y = std.math.sign(ray.y),
        };

        // Information about the wall that ray hits.
        var hit = false;
        var hit_direction: HitDirection = undefined;
        var wall_texture: *const image.Image = undefined;

        // Make sure to not take too many steps.
        for (0..100) |_| {
            // Calculate step factors for moving to the next horizontal/vertical tile.
            const step_factor_x = get_step_factor(tile_rem.x, ray.x);
            const step_factor_y = get_step_factor(tile_rem.y, ray.y);

            var step_factor: f32 = undefined;
            var tile_step: Vec(f32) = undefined;
            if (step_factor_x < step_factor_y) {
                // Move to the next tile in horizontal direction
                step_factor = step_factor_x;
                tile_step = .{ .x = ray_direction.x, .y = 0.0 };
                hit_direction = .horizontal;
            } else {
                // Move to the next tile in vertical direction
                step_factor = step_factor_y;
                tile_step = .{ .x = 0.0, .y = ray_direction.y };
                hit_direction = .vertial;
            }

            // Update tile coordinates.
            tile_idx.x += @intFromFloat(tile_step.x);
            tile_idx.y += @intFromFloat(tile_step.y);

            // Update the tile remainder.
            // rem = rem + ray * dt
            // For x component:
            // If rem.x == 1.0 and ray.x > 0, set rem.x to 0 (we are in new tile)
            // If rem.x == 0.0 and ray.x < 0, set rem.x to 1.0 (we are in new tile)
            // This is done with: -tile_step
            tile_rem = tile_rem.add(&ray.scalar_mul(step_factor).sub(&tile_step));

            // We are out of bounds. Continue instead of exiting in case ray
            // will hit a wall in the future.
            if (tile_idx.x < 0 or tile_idx.y < 0) {
                continue;
            }

            // Check if we hit a wall.
            const tile = game.level.get_tile(@intCast(tile_idx.x), @intCast(tile_idx.y));
            if (tile != null and (tile.? == .wall or tile.? == .door)) {
                wall_texture = switch (tile.?) {
                    .wall => |text| text,
                    .door => |text| text,
                    .empty => unreachable,
                };
                hit = true;
                break;
            }
        }

        // Check that we hit a wall.
        if (!hit) {
            continue;
        }

        // Calculate the distance from camera
        const collision = Vec(f32){
            .x = @as(f32, @floatFromInt(tile_idx.x)) + tile_rem.x,
            .y = @as(f32, @floatFromInt(tile_idx.y)) + tile_rem.y,
        };
        const distance = distance_from_camera(game.player_pos, camera.plane, collision);

        // TODO: Set z buffer
        // for dx in 0..SCALE {
        //   z_buffer[x + dx] = distance;
        // }

        const texture_x = switch (hit_direction) {
            .horizontal => tile_rem.y,
            .vertial => tile_rem.x,
        };

        draw_wall_column(x, wall_texture, texture_x, hit_direction, distance);
    }
}

/// Draws a single column of a wall
fn draw_wall_column(x: usize, wall_texture: *const image.Image, texture_x: f32, hit_direction: HitDirection, distance: f32) void {
    const screen_height_f32: f32 = @floatFromInt(screen.height);

    const real_height = screen_height_f32 / distance * CAMERA_HEIGHT;
    const height = @min(@as(usize, @intFromFloat(real_height)), screen.height);

    var texture_offset: f32 = 0.0;
    if (real_height > screen_height_f32) {
        texture_offset = (real_height - screen_height_f32) / real_height / 2.0;
    }

    const start_y = screen.height / 2 - height / 2;
    const end_y = start_y + height;
    for (start_y..end_y) |y| {
        const texture_y = @as(f32, @floatFromInt(y - start_y)) / real_height + texture_offset;
        var color = wall_texture.get_pixel(texture_x, texture_y);
        if (hit_direction == .horizontal) {
            color.darken(0.5);
        }

        for (0..screen.SCALE) |dx| {
            screen.draw_pixel(x + dx, y, color);
        }
    }
}

fn fraction(val: f32) f32 {
    return val - @trunc(val);
}

/// Auxiliary function to calculate the step factor for moving to the next tile
/// during raycasting. Given tile_rem.x and ray.x it returns t, so that t * ray
/// moves to the  next horizontal tile. Similarly given tile_rem.y and ray.y it
/// returns t, so that t * ray moves to the next vertical tile.
/// x(t) = xRem + ray.x * t
/// y(t) = yRem + ray.y * t
///
/// 0 = xRem + ray.x * t
/// => -xRem / ray.x = t
///
/// 1 = xRem + ray.x * t
/// => (1 - xRem) / ray.x = t
fn get_step_factor(tile_rem_comp: f32, ray_comp: f32) f32 {
    if (ray_comp < 0.0) {
        return -tile_rem_comp / ray_comp;
    } else if (ray_comp > 0.0) {
        return (1.0 - tile_rem_comp) / ray_comp;
    } else {
        return std.math.inf(f32);
    }
}

/// Calculates distance between camera and point. Camera is defined with
/// position and a direction vector.
fn distance_from_camera(position: Vec(f32), direction: Vec(f32), point: Vec(f32)) f32 {
    const pos2 = position.add(&direction);

    const numerator = (pos2.y - position.y) * point.x - (pos2.x - position.x) * point.y + pos2.x * position.y - pos2.y * position.x;
    const denum = direction.length();

    return @abs(numerator) / denum;
}
