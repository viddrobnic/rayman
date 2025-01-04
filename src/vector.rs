#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Vec2 {
    pub x: f32,
    pub y: f32,
}

impl Vec2 {
    pub fn new(x: f32, y: f32) -> Self {
        Self { x, y }
    }

    pub fn zero() -> Self {
        Self::new(0.0, 0.0)
    }

    pub fn from_polar(angle: f32) -> Self {
        Self::new(angle.cos(), angle.sin())
    }

    pub fn rotate_90(&self) -> Self {
        Self::new(-self.y, self.x)
    }

    pub fn scalar_mul(&self, scalar: f32) -> Self {
        Self::new(self.x * scalar, self.y * scalar)
    }
}

impl Default for Vec2 {
    fn default() -> Self {
        Self::zero()
    }
}

impl core::ops::Add for Vec2 {
    type Output = Self;

    fn add(self, rhs: Self) -> Self {
        Self {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

impl core::ops::Sub for Vec2 {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        Self {
            x: self.x - rhs.x,
            y: self.y - rhs.y,
        }
    }
}
