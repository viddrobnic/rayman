pub fn Vec(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn rotate_90(self: *const Self) Self {
            return .{
                .x = -self.y,
                .y = self.x,
            };
        }

        pub fn scalar_mul(self: *const Self, scalar: T) Self {
            return .{
                .x = self.x * scalar,
                .y = self.y * scalar,
            };
        }

        pub fn length(self: *const Self) T {
            return @sqrt(self.x * self.x + self.y * self.y);
        }

        pub fn length_squared(self: *const Self) T {
            return self.x * self.x + self.y * self.y;
        }

        pub fn normalize(self: *const Self) Self {
            const fact = 1.0 / self.length();
            return self.scalar_mul(fact);
        }

        pub fn add(self: *const Self, other: *const Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn sub(self: *const Self, other: *const Self) Self {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
            };
        }

        pub fn dot(self: *const Self, other: *const Self) T {
            return self.x * other.x + self.y * other.y;
        }
    };
}

pub fn from_polar(angle: f32) Vec(f32) {
    return .{
        .x = @cos(angle),
        .y = @sin(angle),
    };
}
