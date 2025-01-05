use crate::color::Color;
use crate::vector::Vec2;
use crate::{draw_pixel, HEIGHT, SCALE, WIDTH};

use super::Game;

const CAMERA_WIDTH: f32 = 1.0;

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
    }
}
