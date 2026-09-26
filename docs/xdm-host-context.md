# Kontext: XDM Headless-Host auf raubach

## Ziel
Der XDM-Downloadmanager soll headless auf raubach (Homelab-Server) laufen.
Die Chrome-Extension läuft lokal auf dem Mac und steuert den Download über
einen SSH-Tunnel. Downloads sollen sauber und dauerhaft in einem Storage
landen, das später von einem selbstgehosteten Mediaserver bedient wird
(NAS-Anbindung und Mediaserver sind SEPARATE, spätere Themen - jetzt nur
der Download-Host).

## Bereits recherchierte technische Fakten

- Repo: https://github.com/subhra74/xdm, bereits lokal geklont.
- Die Chrome-Extension (`app/XDM/chrome-extension`, Manifest V3) hat KEINE
  Native-Messaging-Berechtigung. Sie spricht nur per HTTP-fetch mit
  `http://127.0.0.1:8597` (siehe `connector.js`).
- Der offizielle vorgebaute Linux-Release (`subhra74/xdm-experimental-binaries`,
  8.0.11-beta, Stand 2022) nutzt noch das alte Native-Messaging-Protokoll
  und ist damit INKOMPATIBEL mit der aktuellen Extension. Der Host muss
  daher aus dem aktuellen Source gebaut werden, nicht aus dem Release.
- Host-Projekt: `app/XDM/XDM.Gtk.UI` (GtkSharp-App, .NET).
  - `TargetFramework` steht aktuell auf `net6.0`. .NET 6 ist EOL (Ende 2024)
    und in keinem Paket-Repo mehr installierbar -> muss im Build auf
    `net8.0` angehoben werden.
  - Output-Binary-Name: `xdm-app` (siehe `AssemblyName` im .csproj).
  - Es ist eine echte GTK-Anwendung (`Gtk.Application.Init`) -> braucht
    zwingend eine (auch virtuelle) Grafikausgabe, also Xvfb im Container.
- System-Dependencies laut offiziellem `.deb`-Control-File
  (`app/packaging/deb/DEBIAN/control`): `libgtk-3-0`, `ffmpeg`.
  Zum Bauen zusätzlich `libgtk-3-dev` nötig.
- Post-Build-Schritte laut `app/packaging/packaging.txt`:
  - Ordner `XDM.App.Host` neben der `xdm-app`-Binary anlegen (Inhalt ist
    Windows-spezifisch, auf Linux reicht ein leerer Ordner)
  - Datei `source_pkg.txt` mit Inhalt `tar.xz` daneben anlegen
  - `xdm-logo.svg` daneben kopieren

## Zielarchitektur

- Deployment läuft als Docker-Service auf raubach (Debian 12, bestehendes
  Docker-Compose-Setup, Services liegen unter `/var/projekte/`).
- Dockerfile: Multi-Stage-Build
  - Build-Stage: `dotnet-sdk-8.0`, baut `app/XDM/XDM.Gtk.UI` (inkl.
    TargetFramework-Fix und Post-Build-Schritten)
  - Runtime-Stage: schlankes Image mit `libgtk-3-0`, `ffmpeg`, `xvfb`
- `entrypoint.sh` startet Xvfb (z. B. Display `:99`) und danach `xdm-app`.
- `docker-compose.yml`:
  - Port `8597` NUR auf `127.0.0.1` des Hosts binden (kein LAN-Zugriff)
  - Downloadordner als Volume, Pfad über `.env`-Variable konfigurierbar
    (aktuell lokaler Ordner auf raubach, später Bind-Mount auf nastyNAS,
    sobald die NAS fertig ist - dann genügt eine Änderung der Env-Variable)
- Zugriff vom Mac: `ssh -N -L 8597:127.0.0.1:8597 aaron@raubach.cc`,
  danach lädt Chrome die Extension aus `app/XDM/chrome-extension` als
  entpackte Erweiterung.

## Nicht-Ziele (jetzt)
- NAS-Anbindung (nastyNAS existiert noch nicht)
- Mediaserver-Setup
