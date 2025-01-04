use std::f32::consts::PI;

use crate::texture::TextureManager;
use crate::vector::Vec2;
use level::Level;

mod level;
mod render;

const SPEED: f32 = 1.8;
const ROTATION_SPEED: f32 = 1.8;

#[derive(Debug)]
pub struct Game {
    player_pos: Vec2,
    player_rot: f32,

    level: Level,

    textures: TextureManager,
}

impl Game {
    pub fn new() -> Self {
        Self {
            player_pos: Vec2::new(5.0, 5.0),
            player_rot: 0.1,

            level: Level::one(),

            textures: TextureManager::new(),
        }
    }

    pub fn update(&mut self, dt: f32) {
        self.player_rot += ROTATION_SPEED * dt / 3.0;
        self.player_rot = self.player_rot.rem_euclid(PI);
    }
}
