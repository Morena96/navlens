## 0.1.0

Initial release.

- `NavLensObserver` — `NavigatorObserver` that records push / pop / replace /
  remove events.
- `NavLensController` — process-wide `ChangeNotifier` holding the timeline,
  current stack and parent-to-children flow graph.
- `NavLens.wrap` — draggable debug overlay, auto-hidden in release builds.
- Inspector with three tabs: Current stack, Tree, Timeline.
- `NavLensJsonExporter` — schema-versioned JSON snapshot.
- `NavLensPngExporter` — captures the tree view via `RepaintBoundary.toImage`.
- Rich example app under `example/` demonstrating tabs, nested navigation
  and every navigation primitive.
