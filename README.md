# Pi Automation Starter (Raspberry Pi Zero 2 W)

Ultra-light template for a fast, tiny-footprint automation server on Raspberry Pi Zero 2 W.

## Features
- Single-binary **Go** HTTP server (std lib only)
- `/health`, `/tasks` (list), `/tasks/{name}` (POST to run)
- Example tasks:
  - `blink_led` → calls `scripts/gpio_blink.py` (RPi.GPIO)
  - `scan_wifi` → calls `iwlist wlan0 scan` (no heavy deps)
- Graceful shutdown, small memory usage
- `systemd` unit included for autostart

## Build (cross-compile on your dev machine)
```bash
make build
```

Produces `./server` (ARMv7). Copy the whole folder to the Pi.

## Run on the Pi
```bash
./server
# or
PORT=9090 ./server
```

## API
- `GET /health`
- `GET /tasks` → list available tasks
- `POST /tasks/blink_led?timeout=5s`
- `POST /tasks/scan_wifi`

## Enable on boot (systemd)
```bash
sudo cp deploy/pi-automation.service /etc/systemd/system/pi-automation.service
sudo systemctl daemon-reload
sudo systemctl enable --now pi-automation.service
```

## Dependencies on the Pi
```bash
sudo apt update
sudo apt install -y python3 python3-pip wireless-tools
# RPi.GPIO is usually preinstalled; if not:
# sudo apt install -y python3-rpi.gpio
```

## Safety
- Tasks are **whitelisted** in `internal/tasks/tasks.go`.
- No dynamic shell execution from user input.
- Keep scripts in `./scripts` and register them explicitly.

## Customize
- Add new tasks in `internal/tasks/tasks.go`
- Add more Python or shell scripts in `scripts/`
- Change port via `PORT` env var
```