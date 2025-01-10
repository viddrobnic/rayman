use core::fmt;

use crate::{texture::TextureId, vector::Vec2};

pub trait Entity: fmt::Debug {
    fn get_position(&self) -> Vec2<f32>;
    fn get_size(&self) -> Vec2<f32>;
    fn get_floor_offset(&self) -> f32;

    fn get_texture_id(&self) -> TextureId;
}

#[derive(Debug)]
pub struct DummyEntity {}

impl Entity for DummyEntity {
    fn get_position(&self) -> Vec2<f32> {
        Vec2::new(1.0, 1.0)
    }

    fn get_size(&self) -> Vec2<f32> {
        Vec2::new(0.5, 0.5)
    }

    fn get_floor_offset(&self) -> f32 {
        0.25
    }

    fn get_texture_id(&self) -> TextureId {
        TextureId::Red
    }
}
