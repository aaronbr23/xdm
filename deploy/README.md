# XDM Headless-Host (Docker)

Baut und betreibt den XDM-Downloadmanager headless auf einem Linux-Server
(getestet: Debian 12), gesteuert von der Chrome-Extension per SSH-Tunnel.
Details/Hintergrund: `../docs/xdm-host-context.md`.

## Bauen und Starten

```sh
cd deploy
cp .env.example .env      # DOWNLOAD_DIR ggf. anpassen
docker compose build
docker compose up -d
```

Funktioniert direkt nach `git clone` — keine manuellen Zwischenschritte
(TargetFramework-Fix, Post-Build-Ordner etc. stecken im Dockerfile bzw.
im gepatchten `.csproj`).

## Zugriff vom Mac

```sh
ssh -N -L 8597:127.0.0.1:8597 aaron@raubach.cc
```

Danach in Chrome die Erweiterung aus `../app/XDM/chrome-extension` als
entpackte Erweiterung laden (`chrome://extensions` -> Entwicklermodus ->
"Entpackte Erweiterung laden").

## Troubleshooting

- **Container startet nicht / GTK-Crash**: `docker compose logs xdm`
  pruefen. Meist fehlende Xvfb/Display-Umgebung — `entrypoint.sh` startet
  Xvfb auf `:99` vor `xdm-app`.
- **Verbindungstest ohne Tunnel** (direkt auf dem Server): `curl -sf
  http://127.0.0.1:8597`.
- **Warteschlange/Verlauf nach Neustart weg**: Docker-Volume `xdm-app-data`
  pruefen (`docker volume ls` / `docker volume inspect`) — nicht versehentlich
  mit `docker compose down -v` geloescht.
- **Downloads landen nicht im erwarteten Ordner**: `.env` / `DOWNLOAD_DIR`
  pruefen. Mount-Pfad im Container ist `/root/Downloads`.
- **Port 8597 bereits belegt**: laeuft evtl. ein weiterer XDM-Prozess lokal
  auf dem Server.
