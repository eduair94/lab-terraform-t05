#!/usr/bin/env bash
# AWS "falso" en http://localhost:5000
#   bash scripts/moto.sh start   -> levanta moto (Docker; si no hay Docker, usa Python)
#   bash scripts/moto.sh reset   -> borra TODOS los recursos simulados (como una cuenta nueva)
#   bash scripts/moto.sh stop
set -euo pipefail
case "${1:-start}" in
  start)
    if command -v docker >/dev/null 2>&1; then
      docker run -d --rm --name moto -p 5000:5000 motoserver/moto:5.2.4
    else
      python -m pip install -q "moto[server]"
      nohup python -m moto.server -H 127.0.0.1 -p 5000 > moto.log 2>&1 &
    fi
    until curl -sf http://localhost:5000/moto-api/ >/dev/null; do sleep 1; done
    echo "moto listo en http://localhost:5000  (dashboard: http://localhost:5000/moto-api/)"
    ;;
  reset) curl -sf -X POST http://localhost:5000/moto-api/reset && echo "moto reseteado" ;;
  stop) docker stop moto 2>/dev/null || pkill -f moto.server || true ;;
  *) echo "uso: $0 start|reset|stop"; exit 1 ;;
esac
