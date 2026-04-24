# navlens_example

A runnable demo of the [`navlens`](../) package.

Shows off:

- a tabbed Home screen (Feed + Chat)
- a `Home → Profile → Settings` push chain that matches the tree in the
  NavLens spec
- a Detail screen with buttons for `push`, `pushReplacement`,
  `pushAndRemoveUntil` and `pop`

## Run

```bash
cd example
flutter create .          # regenerates the native platform folders
flutter pub get
flutter run               # or: flutter run -d chrome | -d macos | ...
```

Tap the purple tree button in the bottom-right to open the NavLens
inspector.
