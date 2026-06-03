# Electron Safe Launchers for macOS

Tiny `.app` wrappers that launch Electron/Chromium apps with hardware
acceleration disabled, while copying the original app icon so the launcher can
sit in the Dock.

This helps on Macs where apps such as Chrome, Discord, Slack, or Codex show GPU
rendering artifacts unless started from Terminal with flags.

## Build The Default Launchers

```zsh
cd "/Users/jay/Documents/New project 5/electron-safe-launchers"
./build-default-launchers.zsh
```

The generated launchers will be placed in:

```text
/Users/jay/Documents/New project 5/electron-safe-launchers/Launchers
```

Drag the generated `.app` launchers to the Dock, then remove the original app
icons from the Dock so muscle memory hits the safe launcher.

## Default Apps

The included config builds launchers for:

- Google Chrome
- Discord
- Slack
- Codex

Edit `apps.conf` to add or remove apps.

To replace launchers you already generated:

```zsh
REPLACE_EXISTING=true ./build-default-launchers.zsh
```

## Flags

The default flags are defined in `build-default-launchers.zsh`:

```text
--disable-gpu
--disable-gpu-compositing
--disable-accelerated-video-decode
--disable-features=UseSkiaRenderer,CanvasOopRasterization,Vulkan,Metal
```

If you already have a known-good Terminal command, copy its flags into
`build-default-launchers.zsh` or pass them directly to `build-launcher.zsh`.

## Build One Launcher Manually

```zsh
./build-launcher.zsh \
  "/Applications/Discord.app" \
  "Discord Safe" \
  "./Launchers" \
  --disable-gpu \
  --disable-gpu-compositing
```

## Notes

- The wrapper uses the original app executable inside `Contents/MacOS`.
- The wrapper copies the original icon from the source app bundle.
- If the real app is already running without safe flags, quit it first, then
  launch through the safe wrapper.
