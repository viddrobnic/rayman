use crate::color::Color;
use crate::entity::Entity;
use crate::vector::Vec2;
use crate::{draw_pixel, SCALE};

use super::level::{Tile, Wall};
use super::Game;

const CAMERA_WIDTH: f32 = 1.0;
const CAMERA_HEIGHT: f32 = 1.0;

impl Game {
    pub fn draw(&self) {
        self.draw_floor_ceil();
        self.draw_walls();
        self.draw_sprites();
    }

    fn draw_floor_ceil(&self) {
        let camera_direction = Vec2::<f32>::from_polar(self.player_rot);
        let camera_plane = camera_direction.rotate_90();

        for y in (0..self.height / 2).step_by(SCALE) {
            let camera_factor = 1.0 - 2.0 * (y as f32 / self.height as f32);
            let t = CAMERA_HEIGHT / camera_factor;

            let left = self.player_pos
                + (camera_direction + camera_plane.scalar_mul(CAMERA_WIDTH)).scalar_mul(t);
            let right = self.player_pos
                + (camera_direction - camera_plane.scalar_mul(CAMERA_WIDTH)).scalar_mul(t);

            let diff = right - left;

            for x in (0..self.width).step_by(SCALE) {
                let step = x as f32 / self.width as f32;
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
                        draw_pixel(x + dx, self.height - (y + dy) - 1, floor_color);

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

        for x in (0..self.width).step_by(SCALE) {
            let camera_factor = CAMERA_WIDTH * (1.0 - 2.0 * x as f32 / self.width as f32);
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

    fn draw_sprites(&self) {
        for sprite in &self.sprites {
            self.draw_sprite(&**sprite);
        }
    }

    fn draw_sprite(&self, entity: &dyn Entity) {
        let camera_direction = Vec2::<f32>::from_polar(self.player_rot);
        let camera_plane = camera_direction.rotate_90();

        // Vector between player position and entity.
        let entity_vec = entity.get_position() - self.player_pos;
        let size = entity.get_size();

        // Vector to the left and right position of the entity.
        let entity_right = entity_vec - camera_plane.scalar_mul(size.x / 2.0);
        let entity_left = entity_vec + camera_plane.scalar_mul(size.x / 2.0);

        // Get start and end x coordinates
        let Some(mut start_x) =
            get_entity_screen_x(&camera_direction, &camera_plane, &entity_left, self.width)
        else {
            return;
        };
        let Some(mut end_x) =
            get_entity_screen_x(&camera_direction, &camera_plane, &entity_right, self.width)
        else {
            return;
        };

        // Check if on screen and clip to bounds if necessary.
        if end_x <= 0 || start_x >= self.width as i32 {
            return;
        }

        let width = (end_x - start_x) as f32; // Width before clipping, used for textures
        let texture_x_offset = start_x;
        start_x = start_x.max(0);
        end_x = end_x.min(self.width as i32);

        // Calculate distance from camera.
        let distance = distance_from_camera(self.player_pos, camera_plane, entity.get_position());

        // Calculate height on screen. Basic equation is same as for height of a wall.
        let height = (size.y * self.height as f32 / distance) as i32;

        // Calculate start and end y
        let wall_height = self.height as f32 / distance * CAMERA_HEIGHT;
        let wall_height = wall_height as i32;

        let offset = entity.get_floor_offset() * wall_height as f32;
        let offset = offset as i32;
        let end_y = self.height as i32 / 2 + wall_height / 2 - offset + height / 2;

        let mut start_y = end_y - height;
        let texture_y_offset = start_y;
        start_y = start_y.max(0);
        let end_y = end_y.min(self.height as i32);

        // Render to screen.
        // TODO: z buffer
        // TODO: Sort by distance
        let texture = self.textures.get_texture(entity.get_texture_id());
        for x in (start_x..end_x).step_by(SCALE) {
            let texture_x = (x - texture_x_offset) as f32 / width;
            for y in (start_y..end_y).step_by(SCALE) {
                let texture_y = (y - texture_y_offset) as f32 / height as f32;
                let color = texture.get_pixel(texture_x, texture_y);

                for dx in 0..SCALE {
                    let x = (x as usize + dx).min(self.width - 1);

                    for dy in 0..SCALE {
                        let y = (y as usize + dy).min(self.height - 1);
                        draw_pixel(x, y, color);
                    }
                }
            }
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
        let real_hight = self.height as f32 / distance * CAMERA_HEIGHT;
        let height = real_hight.min(self.height as f32) as usize;

        let texture_offset = if real_hight > self.height as f32 {
            (real_hight - self.height as f32) / real_hight / 2.0
        } else {
            0.0
        };

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

        let start_y = self.height / 2 - height / 2;
        let end_y = start_y + height;
        for y in start_y..end_y {
            let texture_y = (y - start_y) as f32 / real_hight + texture_offset;
            let mut color = texture.get_pixel(texture_x, texture_y);
            if collision_info.hit_direction == HitDirection::Horizontal {
                color.darken(0.5);
            }

            for dx in 0..SCALE {
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

// Calculates x in screen coordinates [0, WIDTH]
fn get_entity_screen_x(
    camera_direction: &Vec2<f32>,
    camera_plane: &Vec2<f32>,
    entity: &Vec2<f32>,
    width: usize,
) -> Option<i32> {
    // Calculate x in camera coordinates, x in [-CAMERA_WIDTH, CAMERA_WIDTH].
    // diff = t * (camera_dir + camera_x * camera_plane)
    // diff x t * (camera_dir + camera_x * camera_plane) = 0  where x is cross product
    // diff x camera_dir + camera_x * diff x camera_plane = 0
    //
    // Because all vector are 2d, cross product will give us 3d vector (0, 0, w).
    // In the following final formula, we are using cross product notation, but
    // have in mind, that values are actually scalars (third component in cross product).
    //
    // camera_x = -(diff x camera_dir) / (diff x camera_plane)
    let denumenator = entity.x * camera_plane.y - entity.y * camera_plane.x;
    if denumenator == 0.0 {
        // If sprite is on the camera plane, we have division by 0.
        return None;
    }

    let numerator = entity.x * camera_direction.y - entity.y * camera_direction.x;
    let camera_x = numerator / denumenator;

    // Transform x into pixel coordinates [0, WIDTH]
    let x = (camera_x + CAMERA_WIDTH) / 2.0 / CAMERA_WIDTH * width as f32;
    Some(x as i32)
}
