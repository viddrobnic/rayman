use crate::color::Color;

#[derive(Debug)]
pub struct Texture {
    width: usize,
    height: usize,
    pixels: Vec<Color>,
}

impl From<Color> for Texture {
    fn from(value: Color) -> Self {
        Self {
            width: 1,
            height: 1,
            pixels: vec![value],
        }
    }
}

impl Texture {
    /// Get the pixel at the given relative coordinates.
    /// x, y in [0, 1]
    pub fn get_pixel(&self, x: f32, y: f32) -> Color {
        let mut x_idx = (x * (self.width as f32)) as usize;
        let mut y_idx = (y * (self.height as f32)) as usize;

        // Handle edge bounds
        if x_idx >= self.width {
            x_idx = self.width - 1
        }
        if y_idx >= self.height {
            y_idx = self.height - 1
        }

        let idx = y_idx * self.width + x_idx;
        self.pixels[idx]
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TextureId {
    Floor1,
    Floor2,
    Green,
    Red,
    Gradient,
}

#[derive(Debug)]
pub struct TextureManager {
    floor1: Texture,
    floor2: Texture,
    green: Texture,
    red: Texture,
    gradient: Texture,
}

impl TextureManager {
    pub fn new() -> Self {
        let gradient = Texture {
            width: 256,
            height: 1,
            pixels: (0..256)
                .map(|i| Color::new(i as u8, i as u8, i as u8))
                .collect(),
        };

        Self {
            floor1: Color::new(0x44, 0x44, 0x44).into(),
            floor2: Color::new(0x66, 0x66, 0x66).into(),
            green: Color::new(0, 0xff, 0).into(),
            red: Color::new(0xff, 0, 0).into(),
            gradient,
        }
    }

    pub fn get_texture(&self, id: TextureId) -> &Texture {
        match id {
            TextureId::Floor1 => &self.floor1,
            TextureId::Floor2 => &self.floor2,
            TextureId::Green => &self.green,
            TextureId::Red => &self.red,
            TextureId::Gradient => &self.gradient,
        }
    }
}
