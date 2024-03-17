# RadGame

## Development

### Installation

TODO
describe godot installation and build template setup

## Running a Dedicated Server

### Server Build

1. Check out repo on server
1. Run `./RadGame_dedicated_server_build.sh`

The dedicated server binary is built into the `builds` directory.

### Server Startup
```
builds/RadGame_dedicated_server.arm64
```

#### Server Parameters

SERVER_PORT: listen on this port (default 4545)

#### Example
```
SERVER_PORT=1234 builds/RadGame_dedicated_server.arm64
```
