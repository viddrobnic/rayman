#[derive(Debug, Clone, Copy)]
pub struct Color {
    pub red: u8,
    pub green: u8,
    pub blue: u8,
    pub alpha: u8,
}

impl Color {
    pub fn new(red: u8, green: u8, blue: u8) -> Self {
        Self {
            red,
            green,
            blue,
            alpha: 255,
        }
    }

    pub fn darken(&mut self, factor: f32) {
        debug_assert!(factor <= 1.0);

        self.red = (self.red as f32 * factor) as u8;
        self.green = (self.green as f32 * factor) as u8;
        self.blue = (self.blue as f32 * factor) as u8;
    }
}
