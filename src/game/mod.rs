use core::f32;
use std::f32::consts::PI;

use crate::entity::DummyEntity;
use crate::vector::Vec2;
use crate::{entity::Entity, texture::TextureManager};
use level::{Level, Tile};

mod level;
mod render;

const SPEED: f32 = 1.8;
const ROTATION_SPEED: f32 = 1.8;

const PLAYER_BOUND_MARGIN: f32 = 0.1;

#[derive(Debug)]
pub struct Game {
    player_pos: Vec2<f32>,
    player_rot: f32,

    level: Level,
    sprites: Vec<Box<dyn Entity>>,
    textures: TextureManager,
}

pub struct UpdateEvent {
    pub dt: f32,

    pub w_pressed: bool,
    pub a_pressed: bool,
    pub s_pressed: bool,
    pub d_pressed: bool,
}

impl Game {
    pub fn new() -> Self {
        Self {
            player_pos: Vec2::new(7.5, 5.0),
            player_rot: f32::consts::PI / 2.0,

            level: Level::one(),
            sprites: vec![Box::new(DummyEntity {})],

            textures: TextureManager::new(),
        }
    }

    pub fn update(&mut self, event: UpdateEvent) {
        let dt = event.dt;

        // Rotate player
        if event.a_pressed {
            self.player_rot += ROTATION_SPEED * dt;
        } else if event.d_pressed {
            self.player_rot -= ROTATION_SPEED * dt;
        }
        self.player_rot = self.player_rot.rem_euclid(2.0 * PI);

        // Move player
        let direction = Vec2::from_polar(self.player_rot);
        let mut move_vec = None;
        if event.w_pressed {
            move_vec = Some(direction.scalar_mul(SPEED * dt));
        } else if event.s_pressed {
            move_vec = Some(direction.scalar_mul(-SPEED * dt));
        }

        let Some(move_vec) = move_vec else {
            return;
        };

        let move_direction = Vec2 {
            x: move_vec.x.total_cmp(&0.0) as i32 as f32,
            y: move_vec.y.total_cmp(&0.0) as i32 as f32,
        };

        let mut new_pos = self.player_pos;

        // Move x
        if matches!(
            self.level.get_tile(
                (new_pos.x + move_vec.x + move_direction.x * PLAYER_BOUND_MARGIN) as usize,
                new_pos.y as usize,
            ),
            Some(Tile::Empty { .. })
        ) {
            new_pos.x += move_vec.x;
        }

        // Move y
        if matches!(
            self.level.get_tile(
                new_pos.x as usize,
                (new_pos.y + move_vec.y + move_direction.y * PLAYER_BOUND_MARGIN) as usize,
            ),
            Some(Tile::Empty { .. })
        ) {
            new_pos.y += move_vec.y;
        }

        self.player_pos = new_pos;
    }
}
