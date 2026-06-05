#!/usr/bin/env bash
set -euo pipefail

DEVICE="${DEVICE:-/dev/video0}"
WIDTH="${WIDTH:-1920}"
HEIGHT="${HEIGHT:-1080}"
FPS="${FPS:-60}"
MODE="${MODE:-auto}"

usage() {
	echo "Usage: $0 [--device /dev/video0] [--width 1920] [--height 1080] [--fps 60] [--mode auto|nv|cpu|ffplay]"
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--device)
			DEVICE="$2"
			shift 2
			;;
		--width)
			WIDTH="$2"
			shift 2
			;;
		--height)
			HEIGHT="$2"
			shift 2
			;;
		--fps)
			FPS="$2"
			shift 2
			;;
		--mode)
			MODE="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage >&2
			exit 1
			;;
	esac
done

if [ ! -e "$DEVICE" ]; then
	echo "Video device not found: $DEVICE" >&2
	exit 1
fi

if command -v v4l2-ctl >/dev/null 2>&1; then
	v4l2-ctl -d "$DEVICE" \
		--set-fmt-video="width=${WIDTH},height=${HEIGHT},pixelformat=UYVY" >/dev/null
fi

if [ "$MODE" = "auto" ]; then
	if command -v gst-inspect-1.0 >/dev/null 2>&1 &&
	   gst-inspect-1.0 nveglglessink >/dev/null 2>&1 &&
	   gst-inspect-1.0 nvvidconv >/dev/null 2>&1; then
		MODE="nv"
	else
		MODE="cpu"
	fi
fi

case "$MODE" in
	nv)
		exec gst-launch-1.0 -v \
			v4l2src device="$DEVICE" io-mode=2 \
			! "video/x-raw,format=UYVY,width=${WIDTH},height=${HEIGHT},framerate=${FPS}/1" \
			! nvvidconv \
			! "video/x-raw(memory:NVMM),format=NV12" \
			! nveglglessink sync=false
		;;
	cpu)
		exec gst-launch-1.0 -v \
			v4l2src device="$DEVICE" io-mode=2 \
			! "video/x-raw,format=UYVY,width=${WIDTH},height=${HEIGHT},framerate=${FPS}/1" \
			! videoconvert \
			! autovideosink sync=false
		;;
	ffplay)
		exec ffplay -f v4l2 \
			-pixel_format uyvy422 \
			-video_size "${WIDTH}x${HEIGHT}" \
			-framerate "$FPS" \
			"$DEVICE"
		;;
	*)
		echo "Unsupported mode: $MODE" >&2
		usage >&2
		exit 1
		;;
esac
