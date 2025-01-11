use core::fmt;

use crate::{texture::TextureId, vector::Vec2};

pub trait Entity: fmt::Debug {
    fn get_position(&self) -> Vec2<f32>;
    fn get_size(&self) -> Vec2<f32>;
    fn get_floor_offset(&self) -> f32;

    fn get_texture_id(&self) -> TextureId;
}

#[derive(Debug)]
pub struct DummyEntity {
    pub pos: Vec2<f32>,
}

impl Entity for DummyEntity {
    fn get_position(&self) -> Vec2<f32> {
        self.pos
    }

    fn get_size(&self) -> Vec2<f32> {
        Vec2::new(0.5, 0.5)
    }

    fn get_floor_offset(&self) -> f32 {
        0.5
    }

    fn get_texture_id(&self) -> TextureId {
        let id = self.pos.x + self.pos.y;
        let id = id as usize;
        let id = id % 3;
        match id {
            0 => TextureId::Red,
            1 => TextureId::Green,
            _ => TextureId::Gradient,
        }
    }
}
