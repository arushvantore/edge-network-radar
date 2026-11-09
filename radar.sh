#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export HOMEBREW_NONINTERACTIVE=1
RADAR_DIR="${HOME}/radar-logs"
BUILD_DIR="/tmp/arp-radar-build"
mkdir -p "${BUILD_DIR}" "${RADAR_DIR}"
if ! command -v arp-scan >/dev/null 2>&1; then brew install arp-scan; fi
docker stop network-radar-service open-webui >/dev/null 2>&1
docker rm network-radar-service open-webui >/dev/null 2>&1
cat > "${BUILD_DIR}/Dockerfile" <<'DOCK'
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends arp-scan iproute2 && rm -rf /var/lib/apt/lists/*
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
DOCK
cat > "${BUILD_DIR}/entry.sh" <<'ENT'
#!/bin/bash
while true; do
  TS="$(date '+%Y-%m-%d %H:%M:%S')"
  GW="$(ip route show default 2>/dev/null | awk 'NR==1 {print $3}')"
  if [ -z "$GW" ]; then GW="10.27.245.1"; fi
  echo "${TS} | \$(arp-scan -I en0 \${GW%.*}.0/24 2>&1)" >> /var/log/arp_radar/scan.log
  sleep 10
done
ENT
chmod +x "${BUILD_DIR}/entry.sh"
docker build -t arp-radar "${BUILD_DIR}" >/dev/null 2>&1
docker run -d --name network-radar-service --restart always --network host --privileged -v "${RADAR_DIR}:/var/log/arp_radar" arp-radar >/dev/null
docker run -d --name open-webui --restart always -p 3000:8080 -v open-webui-radar-data:/app/backend/data -v "${RADAR_DIR}:/app/backend/data/docs/radar:ro" ghcr.io/open-webui/open-webui:main >/dev/null
rm -rf "${BUILD_DIR}"
echo "[+] NETWORK RADAR STACK DEPLOYED SUCCESSFUL!"
echo "[+] Open your browser and go to: http://localhost:3000"
