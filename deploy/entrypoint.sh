#!/bin/sh
set -e
Xvfb :99 -screen 0 1024x768x16 &
export DISPLAY=:99
export GTK_USE_PORTAL=1
exec /app/xdm-app
