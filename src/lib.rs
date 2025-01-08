use color::Color;
use game::{Game, UpdateEvent};

mod color;
mod game;
mod texture;
mod vector;

const WIDTH: usize = 1280;
const HEIGHT: usize = 720;
const SCALE: usize = 2;
static mut SCREEN: [u8; WIDTH * HEIGHT * 4] = [0; WIDTH * HEIGHT * 4];

static mut GAME: Option<Game> = None;

#[no_mangle]
pub extern "C" fn init() {
    unsafe {
        GAME = Some(Game::new());
    }
}

#[no_mangle]
pub extern "C" fn get_screen() -> *const u8 {
    #[allow(static_mut_refs)]
    unsafe {
        SCREEN.as_ptr()
    }
}

#[no_mangle]
pub extern "C" fn draw() {
    unsafe {
        #[allow(static_mut_refs)]
        match &GAME {
            None => panic!("Game not initialized"),
            Some(game) => game.draw(),
        }
    }
}

#[no_mangle]
pub extern "C" fn update(
    dt: f32,
    w_pressed: bool,
    a_pressed: bool,
    s_pressed: bool,
    d_pressed: bool,
) {
    let event = UpdateEvent {
        dt,
        w_pressed,
        a_pressed,
        s_pressed,
        d_pressed,
    };

    unsafe {
        #[allow(static_mut_refs)]
        match &mut GAME {
            None => panic!("Game not initialized"),
            Some(game) => game.update(event),
        }
    }
}

#[inline]
fn draw_pixel(x: usize, y: usize, color: Color) {
    debug_assert!(x < WIDTH, "x {x} out of bounds");
    debug_assert!(y < HEIGHT, "y {y} out of bounds");

    let idx = (y * WIDTH + x) * 4;
    unsafe {
        SCREEN[idx] = color.red;
        SCREEN[idx + 1] = color.green;
        SCREEN[idx + 2] = color.blue;
        SCREEN[idx + 3] = color.alpha;
    }
}
