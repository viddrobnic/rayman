#!/bin/bash

# Default mode
mode="debug"

# Parse the arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --debug) mode="debug"; shift ;;
        --release) mode="release"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Ugly duplication build, but it works
# and it's only two options...
if [[ "$mode" == "debug" ]]; then
    cargo build --target wasm32-unknown-unknown
    wasm-bindgen target/wasm32-unknown-unknown/debug/rayman.wasm --out-dir ./dist --target=web --no-typescript
elif [[ "$mode" == "release" ]]; then
    cargo build --target wasm32-unknown-unknown --release
    wasm-bindgen target/wasm32-unknown-unknown/release/rayman.wasm --out-dir ./dist --target=web --no-typescript
fi

