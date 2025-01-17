# RayMan

Simple web game done using a custom raycasting engine.

## Building and Running

1. Build the `wasm` and move it to correct place:
   ```sh
   zig build
   cp zig-out/bin/rayman.wasm dist/
   ```
2. Run a local server with:
   ```sh
   cd dist
   python3 -m http.server
   ```
3. Open the game at `localhot:8000`

## License

The project is licensed under the [MIT License](LICENSE).
