# menubar-guard

Prevents the macOS cursor from accidentally entering the menu bar.

## Why

On macOS, moving the cursor to the very top of the screen activates the menu bar, which can interrupt full-screen apps, games, or presentations. menubar-guard clamps the cursor a few pixels below the top edge so the menu bar is never triggered by accidental upward movement — you can still reach it deliberately by moving the cursor all the way up and holding it there.

## Install

```sh
brew install derryleng/tap/menubar-guard
```

Then start it and enable it at login:

```sh
brew services start derryleng/tap/menubar-guard
```

On first run, macOS will ask for Accessibility permission. Grant it in:

> System Settings → Privacy & Security → Accessibility

## Usage

menubar-guard runs silently in the background. By default it clamps the cursor 4px below the top edge. You can adjust this threshold by passing a number as the first argument — for example, to use 8px:

```sh
menubar-guard 8
```

To customise the threshold when running as a service, edit the plist at `~/Library/LaunchAgents/homebrew.mxcl.menubar-guard.plist` and change the `ProgramArguments` array, then restart the service.

## Uninstall

```sh
brew services stop derryleng/tap/menubar-guard
brew uninstall menubar-guard
```
