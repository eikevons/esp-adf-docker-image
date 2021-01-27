#!/bin/sh

INSTANCE_NAME=esp-adf-dev
IMAGE_NAME=esp-adf-builder:latest

HOSTDIR="${1:-$PWD}"
HOSTDIR="$(readlink -f "$HOSTDIR")"

if [ ! -d "$HOSTDIR" ]; then
    echo "Not a directory: host directory '$HOSTDIR'" 1>&2
    exit 1
fi

# Take first usb-tty as interface
TTY_ARG=""
for f in /dev/ttyUSB*; do
    if [ -e "$f" ]; then
        TTY_ARG="--device ${f}:/dev/ttyUSB0"
        break
    fi
done
if [ -z "$TTY_ARG" ]; then
    echo "Warning: No usb-tty found" 1>&2
fi

docker run -ti \
    --user "$(id -u)" \
    --volume "$HOSTDIR:/project" \
    --workdir "/project" \
    $TTY_ARG \
    --name "$INSTANCE_NAME" \
    "$IMAGE_NAME"

echo "Note the container instance $INSTANCE_NAME is not yet removed"
