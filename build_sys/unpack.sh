#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

RELEASE_DIR="$SCRIPT_DIR/../release"

# Check if the release directory exists
if [ ! -d "$RELEASE_DIR" ]; then
  echo "Release directory not found: $RELEASE_DIR" >&2
  exit 1
fi

# Change to the release directory
echo "Unpacking release from $RELEASE_DIR"
cd "$RELEASE_DIR" || {
  echo "Failed to change directory to $RELEASE_DIR" >&2
  exit 1
}

# Check for browser specific sub-directories
BROWSERS=(
  "chrome"
  "firefox"
  # "edge"
  # "safari"
)

# the function returns the version of the release
get_version() {
  local version="unknown"
  local browser_release_dir="$1" # "$RELEASE_DIR/chrome"

  # Check if the browser release directory exists
  if [ ! -d "$browser_release_dir" ]; then
    echo "Browser release directory not found: $browser_release_dir" >&2
    echo "$version"
    return
  fi

  # Change to the browser release directory
  cd "$browser_release_dir" || {
    echo "Failed to change directory to $browser_release_dir" >&2
    echo "$version"
    return
  }

  # Look for the zip file and extract the version
  for file in *.zip; do
    if [[ $file =~ ^[a-zA-Z]+-([0-9]+\.[0-9]+\.[0-9]+)\.zip$ ]]; then
      version="${BASH_REMATCH[1]}"
      break
    fi
  done

  echo "$version"
}

# for each browser, unpack the corresponding zip file
for BROWSER in "${BROWSERS[@]}"; do
  # Change to the browser-specific directory
  cd "${BROWSER}" || {
    echo "Failed to change directory to $RELEASE_DIR/$BROWSER" >&2
    exit 1
  }

  # Define the browser release directory
  BROWSER_RELEASE_DIR="$RELEASE_DIR/$BROWSER"

  # Get the version for the browser
  VERSION=$(get_version "$BROWSER_RELEASE_DIR")

  # Check if version was found (not "unknown" and not empty)
  if [ "$VERSION" == "unknown" ] || [ -z "$VERSION" ]; then
    echo "Could not determine version for $BROWSER in $BROWSER_RELEASE_DIR" >&2
    continue
  fi

  # Construct the zip file name
  ZIP_FILE="${BROWSER}-${VERSION}.zip"

  # Check if the zip file exists
  if [ ! -f "$ZIP_FILE" ]; then
    echo "Zip file not found for $BROWSER: $ZIP_FILE" >&2
    continue
  fi

  # Unpack the zip file
  echo "Unpacking $ZIP_FILE for $BROWSER"
  DEST_DIR="$RELEASE_DIR/unpacked_$BROWSER"
  mkdir -p "$DEST_DIR"
  unzip -q "$ZIP_FILE" -d "$DEST_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to unpack $ZIP_FILE" >&2
    exit 1
  fi
  echo "Unpacked $ZIP_FILE to $DEST_DIR"
done
echo "Unpacking completed."

###

exit 0
