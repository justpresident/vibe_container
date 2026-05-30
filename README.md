# Vibe Container

This repository contains a Docker configuration for running AI coding agents in a
containerized development environment.

The image Includes common command-line development tools, GitHub CLI, Rust, Claude Code, Gemini CLI, and OpenAI Codex.
It is intended to mount the current project into `/workspace` and a shared host directory into `/shared`,
giving agents a consistent container while keeping project files on the host.

## Build

```bash
make build
```

This builds the Docker image as `vibe`.

## Recommended Shell Helper

Add this function to your `~/.bash_aliases`:

```bash
vibe_it() {
    CONTAINER_NAME="vibe_$(basename "$PWD")"
    if [[ $1 == 'root' ]]; then
        docker exec -u 0 -it "$CONTAINER_NAME" bash
        return
    fi
    if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
        if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
            docker exec -it "$CONTAINER_NAME" bash
        else
            docker start -ai "$CONTAINER_NAME"
        fi
    else
        mkdir -p ${HOME}/vibe_shared
        docker run --hostname "$CONTAINER_NAME" --name "$CONTAINER_NAME" -it -v "${HOME}/vibe_shared:/shared" -v "$(pwd):/workspace" vibe bash
    fi
}
```

Reload your shell configuration after editing:

```bash
source ~/.bash_aliases
```

## Usage

From the project directory you want to work on, run:

```bash
vibe_it
```

The helper creates or reuses a container named after the current directory, such
as `vibe_my-project`.

To enter the same container as root:

```bash
vibe_it root
```

## Mounted Directories

- Current directory: mounted at `/workspace`
- `${HOME}/vibe_shared`: mounted at `/shared`

Use `/workspace` for the active project and `/shared` for files that should be
available across multiple project containers.
