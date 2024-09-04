import 'package:flutter_to_arch/flutter_to_arch.dart' as flutter_to_arch;
import 'package:io/io.dart';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  var file = File("pubspec.yaml");
  if (!file.existsSync()) {
    print("pubspec.yaml not found");
    exit(1);
  }
  var doc = loadYaml(file.readAsStringSync());
  if (doc['flutter_to_arch'] == null) {
    print("config not found");
    exit(1);
  }
  var pkgName = doc['name'];
  if (pkgName == null) {
    print("name is required");
    exit(1);
  }
  var description = doc['description'];
  if (description == null) {
    print("description is required");
    exit(1);
  }
  var name = doc['flutter_to_arch']['name'];
  if (name == null) {
    print("name is required");
    exit(1);
  }
  var icon = doc['flutter_to_arch']['icon'];
  if (icon == null) {
    print("icon is required");
    exit(1);
  }
  var categories = doc['flutter_to_arch']['categories'];
  if (categories == null) {
    print("categories is required");
    exit(1);
  }
  var keywords = doc['flutter_to_arch']['keywords'];
  if (keywords == null) {
    print("keywords is required");
    exit(1);
  }
  var version = (doc['version'] as String).split('+').first;
  var buildNumber = (doc['version'] as String).split('+')[1];
  var depends = (doc['flutter_to_arch']['depends'] as List?)
      ?.map((e) => "'$e'")
      .join(' ');
  if (depends == null) {
    print("depends is required");
    exit(1);
  }
  var url = doc['flutter_to_arch']['url'];
  if (url == null) {
    print("url is required");
    exit(1);
  }

  var desktopFileContent = flutter_to_arch.generateDesktopFile(
      version, name, pkgName, description, categories, keywords);
  var pkgBuildContent = flutter_to_arch.generatePkgBuild(
      pkgName, description, version, buildNumber, url, depends);
  Directory.current = Directory('${Directory.current.path}/build/linux');
  if (Directory("app").existsSync()) {
    Directory("app").deleteSync(recursive: true);
  }
  Directory("app").createSync(recursive: true);
  copyPathSync("x64/release/bundle/", "app");
  File("app/icon.png").writeAsBytesSync(File("../../$icon").readAsBytesSync());
  File("app/app.desktop").writeAsStringSync(desktopFileContent);
  Process.runSync('tar', ['-czvf', 'app.tar.gz', 'app']);
  Directory("app").deleteSync(recursive: true);
  if (Directory('arch').existsSync()) {
    Directory('arch').deleteSync(recursive: true);
  }
  Directory('arch').createSync(recursive: true);
  File('arch/PKGBUILD').writeAsStringSync(pkgBuildContent);
  File("app.tar.gz").renameSync("arch/app.tar.gz");
  Directory.current = Directory('${Directory.current.path}/arch');
  if (isArchlinux()) {
    var result = Process.runSync('makepkg', ['-s']);
    print(result.stdout);
    print(result.stderr);
    if (result.exitCode != 0) {
      exit(1);
    }
  } else {
    // use docker
    File("Dockerfile").writeAsStringSync(flutter_to_arch.generateDockerFile(depends));
    var result = Process.runSync("docker", ['build', '-t', 'archpkg-builder', '.']);
    print(result.stdout);
    print(result.stderr);
    if (result.exitCode != 0) {
      exit(1);
    }
    result = Process.runSync("docker", ['run', '--rm', '-v', '${Directory.current.absolute.path}:/build', 'archpkg-builder']);
    print(result.stdout);
    print(result.stderr);
    if (result.exitCode != 0) {
      exit(1);
    }
  }

  print(
      "\x1b[32mbuild/linux/arch/$pkgName-$version-$buildNumber-x86_64.pkg.tar.zst\x1b[0m");
}

bool isArchlinux() {
  try {
    Process.runSync('pacman', []);
    return true;
  }
  catch(e) {
    return false;
  }
}