// This is the glue code that initializes the canvas and wasm
// and copies pixels from wasm to canvas.
// Since html, css and js were not the focus of this project, they are very jank...

// Shared objects
const canvas = document.getElementById("game-canvas");
const ctx = canvas.getContext("2d");
let imageData = ctx.createImageData(canvas.width, canvas.height);

let wasm = null;

// Handle key presses
const pressed_keys = {
  w: false,
  a: false,
  s: false,
  d: false,
  space: false,
};
document.onkeydown = function (e) {
  switch (e.key) {
    case "w":
      pressed_keys.w = true;
      break;
    case "a":
      pressed_keys.a = true;
      break;
    case "s":
      pressed_keys.s = true;
      break;
    case "d":
      pressed_keys.d = true;
      break;
    case " ":
      pressed_keys.space = true;
      break;
  }
};

document.onkeyup = function (e) {
  switch (e.key) {
    case "w":
      pressed_keys.w = false;
      break;
    case "a":
      pressed_keys.a = false;
      break;
    case "s":
      pressed_keys.s = false;
      break;
    case "d":
      pressed_keys.d = false;
      break;
    case " ":
      pressed_keys.space = false;
      break;
  }
};

// Handle window resize. Should be called after wasm
// and screen are initialized.
function updateSize() {
  let [width, height] = [window.innerWidth, window.innerHeight];

  // Add some padding
  width -= 32;
  height -= 32;

  // Calculate width and height to have 16/9 ratio.
  let w = width;
  let h = Math.floor((width / 16) * 9);
  if (h > height) {
    h = height;
    w = (width / 9) * 16;
  }

  // Clip if screen is too large.
  w = Math.min(w, 1280);
  h = Math.min(h, 720);

  // Update canvas size
  canvas.width = w;
  canvas.height = h;

  // Update image data into which screen pixels are drawn
  imageData = ctx.createImageData(w, h);

  // If wasm is initialized, notify it of canvas size change
  // and resize screen pixels buffer.
  if (wasm) {
    wasm.set_size(w, h);
  }
}
window.addEventListener("resize", updateSize);

// Main function to load wasm and render stuff
export async function main() {
  wasm = await WebAssembly.instantiateStreaming(fetch("/rayman.wasm"), {
    env: {
      log_int: console.log,
    },
  });
  wasm = wasm.instance.exports;
  const { memory, draw, update, get_screen, init } = wasm;

  // Initialize game and screen pixels buffer
  init(performance.now());

  // Call update size to set initial size
  updateSize();

  // Render loop
  let lastTime = performance.now();
  let frameCount = 0;
  let lastFpsUpdate = performance.now();
  let fps = 0;
  function loop() {
    const now = performance.now();
    const elapsed = now - lastTime;
    lastTime = now;

    // Calculate fps if needed
    if (frameCount > 20) {
      fps = Math.round((frameCount / (now - lastFpsUpdate)) * 1000);
      frameCount = 0;
      lastFpsUpdate = now;
    }
    frameCount++;

    update(
      elapsed / 1000.0,
      pressed_keys.w,
      pressed_keys.a,
      pressed_keys.s,
      pressed_keys.d,
      pressed_keys.space,
    );
    draw(now / 1000.0);

    const screen = new Uint8Array(
      memory.buffer,
      get_screen(),
      canvas.width * canvas.height * 4,
    );
    imageData.data.set(screen);
    ctx.putImageData(imageData, 0, 0);

    // Draw fps as text on context
    ctx.fillStyle = "white";
    ctx.font = "24px sans-serif";
    ctx.fillText(`FPS: ${fps}`, 10, 30);

    requestAnimationFrame(loop);
  }
  requestAnimationFrame(loop);
}
