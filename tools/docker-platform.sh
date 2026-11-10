# Shared Docker platform helpers for BaseOS build scripts.
# Source from a script that has set HERE to the repository root:
#   . "$HERE/tools/docker-platform.sh"
#
# BASEOS_DOCKER_PLATFORM_HOST  — this machine's CPU (no QEMU when possible)
# BASEOS_DOCKER_PLATFORM_AARCH64 — device/userspace arch for the handheld

BASEOS_DOCKER_PLATFORM_AARCH64=linux/arm64

# Device-sized limit. devices.json has no RAM field. docs/06 records the RG28XX
# as 1 GiB LPDDR4; the RG SP runs use the same 1G. fetch-prepared.sh and
# cache-pack.sh pass -m 4G because zstd --long=31 needs a 2 GiB window, and 1G
# kills tar mid-extract.
BASEOS_CONTAINER_MEMORY=1G

container_run() {
  case " $* " in
    *" -m "*|*" --memory "*) command container run "$@" ;;
    *) command container run -m "$BASEOS_CONTAINER_MEMORY" "$@" ;;
  esac
}

case "$(uname -m)" in
  arm64|aarch64) BASEOS_DOCKER_PLATFORM_HOST=linux/arm64 ;;
  x86_64|amd64)  BASEOS_DOCKER_PLATFORM_HOST=linux/amd64 ;;
  *)
    echo "unsupported host architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# Portable file size in bytes. BSD/macOS stat spells this -f %z and GNU/Linux
# -c %s; GNU stat's -f means filesystem, so the two cannot share one form.
file_size() {
  case "$(uname -s)" in
    Darwin|*BSD) stat -f %z "$1" ;;
    *)           stat -c %s "$1" ;;
  esac
}
