mod color;
mod game;
mod vector;

use color::Color;
use game::Game;

static WIDTH: usize = 1280;
static HEIGHT: usize = 720;
static mut SCREEN: [u8; 1280 * 720 * 4] = [0; 1280 * 720 * 4];

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
