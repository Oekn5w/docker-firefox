#
# firefox Dockerfile
#
# https://github.com/jlesage/docker-firefox
#
# Debian based because of upload issue
#

# Pull base image.
FROM jlesage/baseimage-gui:debian-11-v4.4.2

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software versions.
ARG FIREFOX_VERSION=ESR-latestAtBuild

# Define working directory.
WORKDIR /tmp

ARG DEBIAN_FRONTEND=noninteractive

# Install Firefox.
RUN \
    apt-get update && \
    apt-get install -y firefox-esr && \
    apt-get clean

# RUN \
#     apt-get update && \
#     apt-get install -y wget tar bzip2 firefox-esr && \
#     apt-get clean && \
#     wget -O firefoxsetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
#     tar -xvf firefoxsetup.tar.bz2 --directory /opt && \
#     rm firefoxsetup.tar.bz2 && \
#     true

# Install extra packages.
RUN \
    apt-get update && \
    apt-get install -y \
        # WebGL support.
        mesa-utils \
        libgl1-mesa-dri \
        libpci3 \
        libegl-mesa0 \
        llvm-dev xterm \
        # Icons used by folder/file selection window (when saving as).
        adwaita-icon-theme \
        # A font is needed.
        fonts-dejavu \
        # The following package is used to send key presses to the X process.
        xdotool \
        && \
    # Remove unneeded icons.
    find /usr/share/icons/Adwaita -type d -mindepth 1 -maxdepth 1 -not -name 16x16 -not -name scalable -exec rm -rf {} ';' && \
    apt-get clean

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/jlesage/docker-templates/raw/master/jlesage/images/firefox-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
# COPY --from=membarrier /tmp/membarrier_check /usr/bin/

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "Firefox ESR - VNC" && \
    set-cont-env APP_VERSION "$FIREFOX_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Set public environment variables.
ENV \
    FF_OPEN_URL= \
    FF_KIOSK=0

# Metadata.
LABEL \
      org.label-schema.name="firefox" \
      org.label-schema.description="Docker container for Firefox" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-firefox" \
      org.label-schema.schema-version="1.0"
