use crate::color::Color;
use crate::vector::Vec2;
use crate::{draw_pixel, HEIGHT, SCALE, WIDTH};

use super::level::{Tile, Wall};
use super::Game;

const CAMERA_WIDTH: f32 = 0.8;

impl Game {
    pub fn draw(&self) {
        self.draw_floor_ceil();
        self.draw_walls();
    }

    fn draw_floor_ceil(&self) {
        let camera_direction = Vec2::<f32>::from_polar(self.player_rot);
        let camera_plane = camera_direction.rotate_90();

        for y in (0..HEIGHT / 2).step_by(SCALE) {
            let camera_factor = 1.0 - 2.0 * (y as f32 / HEIGHT as f32);
            let t = 1.0 / camera_factor;

            let left = self.player_pos
                + (camera_direction + camera_plane.scalar_mul(CAMERA_WIDTH)).scalar_mul(t);
            let right = self.player_pos
                + (camera_direction - camera_plane.scalar_mul(CAMERA_WIDTH)).scalar_mul(t);

            let diff = right - left;

            for x in (0..WIDTH).step_by(SCALE) {
                let step = x as f32 / WIDTH as f32;
                let pos = left + diff.scalar_mul(step);

                let tile = self.level.get_tile(pos.x as usize, pos.y as usize);
                let Some(tile) = tile else {
                    // We don't have to render floor/ceiling outside of the level,
                    // since levels are bounded by walls and the floor is not visible
                    // outside of the level.
                    continue;
                };

                let (floor_color, ceil_color) = match tile {
                    super::level::Tile::Empty { floor, ceiling } => {
                        let floor_text = self.textures.get_texture(*floor);
                        let ceil_text = self.textures.get_texture(*ceiling);

                        let f_c = floor_text.get_pixel(pos.x.fract(), pos.y.fract());
                        let c_c = ceil_text.get_pixel(pos.x.fract(), pos.y.fract());

                        (f_c, c_c)
                    }
                    super::level::Tile::Wall { .. } => (Color::new(0, 0, 0), Color::new(0, 0, 0)),
                };

                for dy in 0..SCALE {
                    for dx in 0..SCALE {
                        // Draw floor
                        draw_pixel(x + dx, HEIGHT - (y + dy) - 1, floor_color);

                        // Draw ceiling
                        draw_pixel(x + dx, y + dy, ceil_color);
                    }
                }
            }
        }
    }

    fn draw_walls(&self) {
        let camera_direction = Vec2::<f32>::from_polar(self.player_rot);
        let camera_plane = camera_direction.rotate_90();

        let player_idx = Vec2::new(self.player_pos.x as i32, self.player_pos.y as i32);
        let player_rem = Vec2::new(self.player_pos.x.fract(), self.player_pos.y.fract());

        for x in (0..WIDTH).step_by(SCALE) {
            let camera_factor = CAMERA_WIDTH * (1.0 - 2.0 * x as f32 / WIDTH as f32);
            let camera_point = camera_plane.scalar_mul(camera_factor);
            let ray = camera_direction + camera_point;

            let mut tile_idx = player_idx; // Index of tile we are on.
            let mut tile_rem = player_rem; // Position inside the tile.
            let ray_direction =
                Vec2::new(ray.x.total_cmp(&0.0) as i32, ray.y.total_cmp(&0.0) as i32);

            // Wall that the ray hit and from which direction it hit.
            let mut collision_info = None;

            // Make sure to not take too many steps.
            for _step in 0..100 {
                // Calculate step factors for moving to the next horizontal/vertical tile.
                let step_factor_x = get_step_factor(tile_rem.x, ray.x);
                let step_factor_y = get_step_factor(tile_rem.y, ray.y);

                let step_factor;
                let tile_step;
                let hit_direction;
                if step_factor_x < step_factor_y {
                    // Move to the next tile in horizontal direction
                    step_factor = step_factor_x;
                    tile_step = Vec2::new(ray_direction.x, 0);
                    hit_direction = HitDirection::Horizontal;
                } else {
                    // Move to the next tile in vertical direction
                    step_factor = step_factor_y;
                    tile_step = Vec2::new(0, ray_direction.y);
                    hit_direction = HitDirection::Vertical;
                }

                // Update tile coordinates.
                tile_idx += tile_step;

                // Update the tile remainder.
                // rem = rem + ray * dt
                // For x component:
                // If rem.x == 1.0 and ray.x > 0, set rem.x to 0 (we are in new tile)
                // If rem.x == 0.0 and ray.x < 0, set rem.x to 1.0 (we are in new tile)
                // This is done with -dxIdx
                let tile_step_f32 = Vec2::new(tile_step.x as f32, tile_step.y as f32);
                tile_rem += ray.scalar_mul(step_factor) - tile_step_f32;

                if tile_idx.x < 0 || tile_idx.y < 0 {
                    continue;
                }

                let tile = self
                    .level
                    .get_tile(tile_idx.x as usize, tile_idx.y as usize);

                if let Some(Tile::Wall(wall)) = tile {
                    collision_info = Some(CollisionInfo {
                        wall,
                        hit_direction,
                    });
                    break;
                }
            }

            // Check that we hit a wall.
            let Some(collision_info) = collision_info else {
                continue;
            };

            // Calculate the height of the column.
            let collision = Vec2 {
                x: tile_idx.x as f32 + tile_rem.x,
                y: tile_idx.y as f32 + tile_rem.y,
            };
            let distance = distance_from_camera(self.player_pos, camera_plane, collision);

            let texture_x = match collision_info.hit_direction {
                HitDirection::Horizontal => tile_rem.y,
                HitDirection::Vertical => tile_rem.x,
            };
            debug_assert!(
                (0.0..=1.0).contains(&texture_x),
                "texture coordinate out of bounds: {texture_x}"
            );

            // Draw the column
            self.draw_wall_column(x, collision_info, texture_x, distance, ray_direction);
        }
    }

    fn draw_wall_column(
        &self,
        x: usize,
        collision_info: CollisionInfo,
        texture_x: f32,
        distance: f32,
        ray_direction: Vec2<i32>,
    ) {
        let height = (HEIGHT as f32 / distance).min(HEIGHT as f32);
        let height = height as usize;

        // Get the color
        let wall = collision_info.wall;
        let texture_id = match collision_info.hit_direction {
            HitDirection::Horizontal if ray_direction.x == -1 => wall.east,
            HitDirection::Horizontal if ray_direction.x == 1 => wall.west,
            HitDirection::Vertical if ray_direction.y == -1 => wall.north,
            HitDirection::Vertical if ray_direction.y == 1 => wall.south,
            _ => unreachable!(),
        };
        let texture = self.textures.get_texture(texture_id);

        let start_y = HEIGHT / 2 - height / 2;
        let end_y = start_y + height;
        for dx in 0..SCALE {
            for y in start_y..end_y {
                let texture_y = (y - start_y) as f32 / (end_y as f32 - start_y as f32);
                let mut color = texture.get_pixel(texture_x, texture_y);

                if collision_info.hit_direction == HitDirection::Horizontal {
                    color.darken(0.5);
                }

                draw_pixel(x + dx, y, color);
            }
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum HitDirection {
    Horizontal,
    Vertical,
}

struct CollisionInfo<'a> {
    wall: &'a Wall,
    hit_direction: HitDirection,
}

// Auxiliary function to calculate the step factor for moving to the next tile
// during raycasting. Given tile_rem.x and ray.x it returns t, so that t * ray
// moves to the  next horizontal tile. Similarly given tile_rem.y and ray.y it
// returns t, so that t * ray moves to the next vertical tile.
// x(t) = xRem + ray.x * t
// y(t) = yRem + ray.y * t
//
// 0 = xRem + ray.x * t
// => -xRem / ray.x = t
//
// 1 = xRem + ray.x * t
// => (1 - xRem) / ray.x = t
fn get_step_factor(tile_rem_comp: f32, ray_comp: f32) -> f32 {
    if ray_comp < 0.0 {
        -tile_rem_comp / ray_comp
    } else if ray_comp > 0.0 {
        (1.0 - tile_rem_comp) / ray_comp
    } else {
        f32::INFINITY
    }
}

// Calculates distance between camera and point. Camera is defined with
// position and a direction vector.
fn distance_from_camera(position: Vec2<f32>, direction: Vec2<f32>, point: Vec2<f32>) -> f32 {
    let pos2 = position + direction;

    let numerator = (pos2.y - position.y) * point.x - (pos2.x - position.x) * point.y
        + pos2.x * position.y
        - pos2.y * position.x;
    let denum = direction.length();

    numerator.abs() / denum
}
