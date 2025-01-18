pub fn Vec(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn rotate_90(self: *const Self) Self {
            return .{ -self.y, self.x };
        }

        pub fn scalar_mul(self: *const Self, scalar: T) Self {
            return .{ self.x * scalar, self.y * scalar };
        }

        pub fn length(self: *const Self) T {
            @sqrt(self.x * self.x + self.y * self.y);
        }

        pub fn add(self: *const Self, other: *const Self) Self {
            return .{ self.x + other.x, self.y + other.y };
        }

        pub fn sub(self: *const Self, other: *const Self) Self {
            return .{ self.x - other.x, self.y - other.y };
        }
    };
}

pub fn from_polar(angle: f32) Vec(f32) {
    return .{ @cos(angle), @sin(angle) };
}
