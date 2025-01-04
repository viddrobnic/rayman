use crate::texture::TextureManager;
use crate::vector::Vec2;
use level::Level;

mod level;
mod render;

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
}
