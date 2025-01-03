use crate::color::Color;
use crate::vector::Vec2;
use crate::{draw_pixel, HEIGHT, WIDTH};

pub struct Game {
    player_pos: Vec2,
    player_rot: f32,
}

impl Game {
    pub fn new() -> Self {
        Self {
            player_pos: Vec2::zero(),
            player_rot: 0.0,
        }
    }

    pub fn draw(&self) {
        draw_floor();
        draw_ceiling();
    }
}

fn draw_floor() {
    for y in HEIGHT / 2..HEIGHT {
        for x in 0..WIDTH {
            draw_pixel(x, y, Color::new(0x44, 0x44, 0x44));
        }
    }
}

fn draw_ceiling() {
    for y in 0..HEIGHT / 2 {
        for x in 0..WIDTH {
            draw_pixel(x, y, Color::new(0x66, 0x66, 0x66));
        }
    }
}
