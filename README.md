# conf-import

Containerized DNS zone import tool for Cloudflare

## Features
- Interactive and non-interactive DNS zone import
- Outputs Cloudflare-compatible JSON
- Optionally pushes records directly to Cloudflare
- Portable install via shell script or Docker

## Quick Start

### Native Install (Linux/macOS/WSL)
```sh
bash zone-tool-install.sh
zone-import -h
```

### Docker Usage
```sh
docker build -t zone-import .
docker run --rm -it zone-import
```

## Structure
- `zone-tool-install.sh` – One-step installer for native environments
- `Dockerfile` – Container build for development/portability
- `src/` – Source code and executable
- `tests/` – (To be added) Test scripts and cases

## License
MIT
