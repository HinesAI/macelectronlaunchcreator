# Electron Safe Launchers for macOS

Build small macOS `.app` wrapper launchers that start Electron or
Chromium-based apps with GPU and hardware acceleration flags disabled.

The generated launchers can be placed in the Dock and use the original app icon,
so you can launch the safer version without remembering a Terminal command.

This is useful on Macs where apps such as Chrome, Discord, Slack, Codex, or
other Electron apps show GPU artifacts, red boxes, blank windows, freezes, or
other rendering problems unless launched with hardware acceleration disabled.

## What This Does

- Creates a lightweight `.app` wrapper for each configured app.
- Reads the real app executable from the source app's `Info.plist`.
- Copies the source app icon into the generated wrapper.
- Launches the real app binary with configurable Electron/Chromium flags.
- Lets the generated wrapper sit in the Dock like a normal app.

## What This Does Not Do

- It does not modify the original application.
- It does not patch, resign, or repackage the original app.
- It does not disable hardware acceleration globally.
- It does not guarantee every Electron or Chromium app accepts every flag.
- It does not fix underlying GPU, driver, OpenCore, or macOS compatibility
  issues.

This is a convenience wrapper for known-good launch flags, not a system repair
tool.

## Public Repository Note

Do not commit generated launchers to a public repository.

Generated `.app` bundles may contain copied icons from third-party apps such as
Chrome, Discord, Slack, or Codex. Those icons belong to their respective owners.
This repository should contain the scripts and config only; each user should
generate launchers locally on their own Mac.

The included `.gitignore` excludes:

```text
Launchers/
*.zip
```

## Requirements

- macOS
- zsh
- Standard macOS tools: `PlistBuddy`, `plutil`, `find`, `sed`, `tr`
- Source apps installed locally, usually in `/Applications`

## Files

```text
build-default-launchers.zsh   Builds all launchers listed in apps.conf
build-launcher.zsh            Builds one launcher
apps.conf                     Default app list
README.md                     This file
```

## Default Apps

The included `apps.conf` builds launchers for:

- Google Chrome
- Discord
- Slack
- Codex

The config format is:

```text
Launcher Display Name|/path/to/Source App.app
```

Example:

```text
Discord Safe|/Applications/Discord.app
```

## Build Default Launchers

From this folder:

```zsh
./build-default-launchers.zsh
```

Generated launchers are written to:

```text
./Launchers
```

Drag the generated `.app` launchers to the Dock. Then remove the original app
icons from the Dock so accidental Dock launches use the safe wrapper.

## Replace Existing Launchers

The builder refuses to overwrite existing launchers by default.

To rebuild:

```zsh
REPLACE_EXISTING=true ./build-default-launchers.zsh
```

## Build One Launcher Manually

```zsh
./build-launcher.zsh \
  "/Applications/Discord.app" \
  "Discord Safe" \
  "./Launchers" \
  --disable-gpu \
  --disable-gpu-compositing
```

Arguments:

```text
1. Source .app path
2. Generated launcher display name
3. Output directory
4. Flags passed to the real app executable
```

## Default Flags

The default flags are defined in `build-default-launchers.zsh`:

```text
--disable-gpu
--disable-gpu-compositing
--disable-accelerated-video-decode
--disable-features=UseSkiaRenderer,CanvasOopRasterization,Vulkan,Metal
```

If you already have a known-good Terminal command for your Mac, copy those flags
into `build-default-launchers.zsh` or pass them directly to
`build-launcher.zsh`.

## Important Usage Notes

- Quit the original app before launching through the safe wrapper.
- If the app is already running from the normal Dock icon, macOS may reuse the
  existing unsafe process.
- Some apps update themselves and change executable names or bundle layout. If a
  launcher stops working after an app update, rebuild it.
- Keep the original app installed. The safe launcher starts the original app; it
  does not contain a copy of the app.
- macOS may show a first-launch warning for locally generated apps.

## Troubleshooting

If a launcher opens but the app still renders incorrectly:

- Confirm the original app was fully quit first.
- Try adding or removing flags.
- Rebuild after app updates:

  ```zsh
  REPLACE_EXISTING=true ./build-default-launchers.zsh
  ```

- Test the equivalent Terminal command directly to confirm the flags work for
  that app.

If a launcher says it cannot find the real app executable:

- Confirm the source app path in `apps.conf` exists.
- Confirm the app is installed in `/Applications` or update the path.
- Rebuild the launcher.

## Uninstall

Remove the generated launcher from the Dock, then delete it from:

```text
./Launchers
```

This does not affect the original app.

## Attribution

Created by HinesAI.
