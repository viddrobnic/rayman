const Self = @This();

red: u8,
green: u8,
blue: u8,
alpha: u8,

pub fn new(red: u8, green: u8, blue: u8) Self {
    return .{
        .red = red,
        .green = green,
        .blue = blue,
        .alpha = 255,
    };
}

pub fn darken(self: *Self, factor: f32) void {
    self.red = @intFromFloat(@as(f32, @floatFromInt(self.red)) * factor);
    self.green = @intFromFloat(@as(f32, @floatFromInt(self.green)) * factor);
    self.blue = @intFromFloat(@as(f32, @floatFromInt(self.blue)) * factor);
}
