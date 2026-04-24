# NavLens

**Runtime navigation visualizer for Flutter.**
See exactly how your app moves between screens, live, inside the app.

NavLens turns invisible `Navigator` events into a debug overlay that shows
the current stack, a tree of visited screens, a chronological timeline of
pushes and pops, and one-tap JSON / PNG export — without pulling in any
dependencies.

## Why

Flutter navigation is hard to debug. You end up guessing at the stack,
scattering `print` statements, or wading through framework logs. NavLens
makes the flow visible:

- what screen is active right now
- how screens connect to each other
- what happened, step by step, to get here

## Install

Add to `pubspec.yaml`:

```yaml
dependencies:
  navlens:
    git: https://github.com/Morena96/navlens.git
```

## Two-line setup

```dart
import 'package:flutter/material.dart';
import 'package:navlens/navlens.dart';

MaterialApp(
  navigatorObservers: [NavLensObserver()],
  builder: (context, child) =>
      NavLens.wrap(child: child ?? const SizedBox.shrink()),
  home: const HomeScreen(),
);
```

That's it. A draggable NavLens button appears in debug and profile builds
(hidden automatically in release). Tap it to open the inspector.

> Using `builder:` places the overlay inside the `MaterialApp` so it has
> access to the Navigator, theme, `MediaQuery`, and `ScaffoldMessenger`
> while still floating above every screen.

## What you get

### Current stack

Shows the live `Navigator` stack, bottom to top, with the visible route
highlighted.

### Tree view

A historical tree of every screen the app has pushed onto another, rendered
with the familiar indent guides:

```
Home
├── Chat
└── Profile
    └── Settings
```

The currently active node is highlighted.

### Timeline

A reverse-chronological list of every `push`, `pop`, `replace` and `remove`,
with icons, previous-route context and timestamps.

### Export

The inspector's app bar has one-tap actions to:

- Copy the navigation graph as JSON (schema-versioned, stable)
- Capture the tree view as a PNG

You can also call the APIs directly:

```dart
final json = const NavLensJsonExporter().export();
final pngBytes = await const NavLensPngExporter().export(
  boundaryKey: myRepaintBoundaryKey,
);
```

## Works with any router

`NavLensObserver` is a plain `NavigatorObserver`, so it slots straight into
`MaterialApp.navigatorObservers`, `go_router`'s `observers`, `auto_route`'s
`navigatorObservers`, or any other router that builds on `Navigator` 1.0
under the hood.

## Platform support

NavLens is pure Flutter — no platform channels, no plugins — so it runs
everywhere Flutter does:

| Android | iOS | Web | macOS | Windows | Linux |
| :-----: | :-: | :-: | :---: | :-----: | :---: |
| yes | yes | yes | yes | yes | yes |

## Example app

The `example/` folder contains a runnable demo with:

- a tabbed `Home` (Feed + Chat)
- a `Home → Profile → Settings` push chain matching the spec tree
- a `Detail` screen with buttons for `push`, `pushReplacement`,
  `pushAndRemoveUntil` and `pop`

```bash
cd example
flutter run
```

## V1 feature set

- Live current-stack view
- Historical flow tree
- Push / pop / replace / remove timeline
- Draggable debug overlay button (release-safe)
- JSON export (schema-versioned)
- PNG export via `RepaintBoundary`

## Roadmap

- Full declarative navigation graph (complete app flow, ahead of time)
- Automatic route discovery without running the app
- CLI for generating graphs offline
- Diff between planned vs. actual navigation

## License

MIT.
