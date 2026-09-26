FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
RUN apt-get update && apt-get install -y --no-install-recommends libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . .
RUN dotnet publish app/XDM/XDM.Gtk.UI/XDM.Gtk.UI.csproj \
    -c Release -r linux-x64 --self-contained false -p:PublishTrimmed=false -o /out \
    && mkdir -p /out/XDM.App.Host

FROM mcr.microsoft.com/dotnet/runtime:8.0
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgtk-3-0 ffmpeg xvfb ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /out /app
COPY deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
