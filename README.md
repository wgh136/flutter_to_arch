# flutter_to_arch

A command-line application to bundle your flutter app build into a archlinux package.

## Usage

- Add to `pubspec.yaml`
```yaml
dev_dependencies:
  flutter_to_arch:
    path: https://github.com/wgh136/flutter_to_arch
```

- run `flutter pub get`

- Write configs at the end of `pubspec.yaml`
```yaml
flutter_to_arch:
  name: myapp
  icon: linux/icon.png
  categories: Utility
  keywords: Flutter;Utility;
  url: https://example.com
  depends: 
    - gtk3
```

- build linux
```sh
flutter build linux
```

- build archlinux package
```sh
dart run flutter_to_arch
```
