#!/usr/bin/env sh

set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
EXAMPLES_ROOT="$REPO_ROOT/examples"
OUTPUT_ROOT="$REPO_ROOT/examples-bin"

if ! command -v lazbuild >/dev/null 2>&1; then
  echo "lazbuild was not found in PATH" >&2
  exit 1
fi

case "$OUTPUT_ROOT" in
  "$REPO_ROOT/examples-bin") ;;
  *)
    echo "Refusing unexpected output path: $OUTPUT_ROOT" >&2
    exit 1
    ;;
esac

if [ -d "$OUTPUT_ROOT" ]; then
  rm -rf "$OUTPUT_ROOT"
fi
mkdir -p "$OUTPUT_ROOT"

count=0
for project in "$EXAMPLES_ROOT"/*/*.lpi; do
  if [ ! -f "$project" ]; then
    continue
  fi

  name=$(basename "$project" .lpi)
  unit_output="$OUTPUT_ROOT/units/$name"
  mkdir -p "$unit_output"

  echo "Building $name"
  lazbuild \
    --build-all \
    --build-mode=Release \
    --no-write-project \
    "--opt=-FE$OUTPUT_ROOT" \
    "--opt=-FU$unit_output" \
    "--opt=-FcUTF8" \
    "$project"

  if [ ! -f "$OUTPUT_ROOT/$name" ]; then
    echo "Build succeeded but executable was not found: $OUTPUT_ROOT/$name" >&2
    exit 1
  fi

  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  echo "No canonical Lazarus example projects were found." >&2
  exit 1
fi

echo "Built $count examples in $OUTPUT_ROOT"
