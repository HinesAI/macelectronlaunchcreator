#!/bin/zsh

set -euo pipefail

usage() {
  /bin/echo "Usage: $0 /Applications/App.app 'App Safe' ./Launchers [flags...]"
}

if (( $# < 3 )); then
  usage
  exit 64
fi

SOURCE_APP="$1"
DISPLAY_NAME="$2"
OUTPUT_DIR="$3"
shift 3

FLAGS=("$@")
INFO_PLIST="${SOURCE_APP}/Contents/Info.plist"
REPLACE_EXISTING="${REPLACE_EXISTING:-false}"

if [[ ! -d "$SOURCE_APP" ]]; then
  /bin/echo "Source app not found: ${SOURCE_APP}" >&2
  exit 66
fi

if [[ ! -f "$INFO_PLIST" ]]; then
  /bin/echo "Source app Info.plist not found: ${INFO_PLIST}" >&2
  exit 66
fi

REAL_EXECUTABLE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$INFO_PLIST")"
REAL_BINARY="${SOURCE_APP}/Contents/MacOS/${REAL_EXECUTABLE}"

if [[ ! -x "$REAL_BINARY" ]]; then
  /bin/echo "Source app executable not found: ${REAL_BINARY}" >&2
  exit 66
fi

safe_id="$(/bin/echo "$DISPLAY_NAME" | /usr/bin/tr '[:upper:]' '[:lower:]' | /usr/bin/sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
BUNDLE_ID="local.safe-launcher.${safe_id}"
TARGET_APP="${OUTPUT_DIR}/${DISPLAY_NAME}.app"
TARGET_CONTENTS="${TARGET_APP}/Contents"
TARGET_MACOS="${TARGET_CONTENTS}/MacOS"
TARGET_RESOURCES="${TARGET_CONTENTS}/Resources"
TARGET_EXECUTABLE="safe-launcher"
ICON_BASENAME="AppIcon.icns"
TARGET_ICON="${TARGET_RESOURCES}/${ICON_BASENAME}"

if [[ -e "$TARGET_APP" ]]; then
  if [[ "$REPLACE_EXISTING" != "true" ]]; then
    /bin/echo "Target already exists: ${TARGET_APP}" >&2
    /bin/echo "Set REPLACE_EXISTING=true to rebuild it." >&2
    exit 73
  fi

  /bin/rm -rf "$TARGET_APP"
fi

/bin/mkdir -p "$TARGET_MACOS" "$TARGET_RESOURCES"

icon_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$INFO_PLIST" 2>/dev/null || true)"
if [[ -n "$icon_name" ]]; then
  icon_file="$icon_name"
  if [[ "$icon_file" != *.icns ]]; then
    icon_file="${icon_file}.icns"
  fi

  if [[ -f "${SOURCE_APP}/Contents/Resources/${icon_file}" ]]; then
    /bin/cp "${SOURCE_APP}/Contents/Resources/${icon_file}" "$TARGET_ICON"
  fi
fi

if [[ ! -f "$TARGET_ICON" ]]; then
  first_icon="$(/usr/bin/find "${SOURCE_APP}/Contents/Resources" -maxdepth 1 -name '*.icns' -print -quit 2>/dev/null || true)"
  if [[ -n "$first_icon" ]]; then
    /bin/cp "$first_icon" "$TARGET_ICON"
  fi
fi

{
  /bin/echo "#!/bin/zsh"
  /bin/echo
  /bin/echo "set -u"
  /bin/echo
  /bin/echo "REAL_APP=${(qqq)SOURCE_APP}"
  /bin/echo "REAL_EXECUTABLE=${(qqq)REAL_EXECUTABLE}"
  /bin/echo 'REAL_BINARY="${REAL_APP}/Contents/MacOS/${REAL_EXECUTABLE}"'
  /bin/echo
  /bin/echo "FLAGS=("
  for flag in "${FLAGS[@]}"; do
    /bin/echo "  ${(qqq)flag}"
  done
  /bin/echo ")"
  /bin/echo
  /bin/echo 'if [[ ! -x "$REAL_BINARY" ]]; then'
  /bin/echo '  /usr/bin/osascript -e "display alert \"Safe launcher cannot find the real app executable.\" message \"${REAL_BINARY}\" as critical"'
  /bin/echo "  exit 66"
  /bin/echo "fi"
  /bin/echo
  /bin/echo 'cd "${REAL_APP}/Contents/MacOS" || exit 1'
  /bin/echo 'exec "$REAL_BINARY" "${FLAGS[@]}" "$@"'
} > "${TARGET_MACOS}/${TARGET_EXECUTABLE}"

/bin/chmod +x "${TARGET_MACOS}/${TARGET_EXECUTABLE}"

/bin/cat > "${TARGET_CONTENTS}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${DISPLAY_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${TARGET_EXECUTABLE}</string>
  <key>CFBundleIconFile</key>
  <string>${ICON_BASENAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${DISPLAY_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>10.13</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "${TARGET_CONTENTS}/Info.plist" >/dev/null
/usr/bin/touch "$TARGET_APP"

/bin/echo "Built ${TARGET_APP}"
