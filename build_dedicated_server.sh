#!/bin/sh

mkdir -p build

# build linux arm64 server binary
godot --headless --path src --export-release linux_dedicated_server_arm64 ../build/RadGame_dedicated_server.arm64
