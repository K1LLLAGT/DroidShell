# DroidShell Desktop Companion

Scaffold for a future cross-platform desktop companion app.

## Suggested stacks

| Stack      | Notes                                       |
|------------|---------------------------------------------|
| Tauri      | Rust + WebView, small binary, recommended   |
| Electron   | Node + Chromium, larger but familiar        |
| Flask+WebView | Python, easiest for rapid prototyping   |

## Features (planned)

- Connect to device API server (ds-api.sh)
- Live log viewer (ws://device:9090 via ds-log-stream.sh)
- Package manager UI
- OTA update trigger + progress
- Plugin permission manager
- Cross-device sync control (ds-sync.sh)

## Quick start (Flask prototype)

```bash
pip install flask flask-cors
python src/app.py
```
