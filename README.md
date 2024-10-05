# RadGame

Documentation of RadGame can be found on https://wiki.shiny.space/shelves/radgame

## Development

### Installation

#### git lfs

Run `git lfs install` once inside the git repo. If it doesn't work, download the git extension here: [git-lfs.com](https://git-lfs.com/)

LFS is hosted on `git@forge.shiny.space:miejs/RadGameLFS.git`.
- Make an account there, add an ssh key, and load the key (like accessing any other git repo)
- Ask for access to the above repo

Then you should be able to `git pull` and the files in lfs will be downloaded.

#### Godot

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
