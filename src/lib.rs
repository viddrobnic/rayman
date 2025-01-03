static WIDTH: usize = 1280;
static HEIGHT: usize = 720;
static mut SCREEN: [u8; 1280 * 720 * 4] = [0; 1280 * 720 * 4];

#[no_mangle]
pub extern "C" fn get_screen() -> *const u8 {
    #[allow(static_mut_refs)]
    unsafe {
        SCREEN.as_ptr()
    }
}

#[no_mangle]
pub extern "C" fn draw(t: f32) {
    let val = (t.sin() * 255.0) as u8;
    let color = Color::new(val, val, val);

    for y in 0..HEIGHT {
        for x in 0..WIDTH {
            draw_pixel(x, y, color);
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct Color {
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
}

#[inline]
fn draw_pixel(x: usize, y: usize, color: Color) {
    let idx = (y * WIDTH + x) * 4;
    unsafe {
        SCREEN[idx] = color.red;
        SCREEN[idx + 1] = color.green;
        SCREEN[idx + 2] = color.blue;
        SCREEN[idx + 3] = color.alpha;
    }
}
