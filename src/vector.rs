use std::ops::{Add, AddAssign, Mul, Neg, Sub};

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Vec2<T> {
    pub x: T,
    pub y: T,
}

impl<T> Vec2<T> {
    pub fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Mul<Output = T> + Neg<Output = T> + Copy> Vec2<T> {
    pub fn rotate_90(&self) -> Self {
        Self::new(-self.y, self.x)
    }

    pub fn scalar_mul(&self, scalar: T) -> Self {
        Self::new(self.x * scalar, self.y * scalar)
    }
}

impl<T: Mul<Output = T> + Add<Output = T> + Copy> Vec2<T> {
    pub fn dot_product(&self, other: &Vec2<T>) -> T {
        self.x * other.x + self.y * other.y
    }
}

impl<T: Default> Default for Vec2<T> {
    fn default() -> Self {
        Self::new(T::default(), T::default())
    }
}

impl Vec2<f32> {
    pub fn from_polar(angle: f32) -> Self {
        Self::new(angle.cos(), angle.sin())
    }

    pub fn length(&self) -> f32 {
        (self.x * self.x + self.y * self.y).sqrt()
    }
}

impl<T: Add<Output = T>> Add for Vec2<T> {
    type Output = Self;

    fn add(self, rhs: Self) -> Self {
        Self {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

impl<T: AddAssign> AddAssign for Vec2<T> {
    fn add_assign(&mut self, rhs: Self) {
        self.x += rhs.x;
        self.y += rhs.y;
    }
}

impl<T: Sub<Output = T>> Sub for Vec2<T> {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        Self {
            x: self.x - rhs.x,
            y: self.y - rhs.y,
        }
    }
}
