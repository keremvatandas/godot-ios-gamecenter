#!/usr/bin/env python3
from __future__ import annotations

import configparser
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tempfile
from zipfile import ZipFile


ADDON_ROOT = "addons/gamecenter/"
EXPECTED_VERSION = "1.0.0"


class ValidationError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def run(*command: str, cwd: Path | None = None) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        raise ValidationError(f"{' '.join(command)} failed: {detail}")
    return result.stdout


def require_entry(names: set[str], relative_path: str) -> None:
    entry = ADDON_ROOT + relative_path
    exists = entry in names or any(name.startswith(entry.rstrip("/") + "/") for name in names)
    require(exists, f"missing package entry: {entry}")


def inspect_symbol(binary: Path) -> None:
    symbols = run("nm", "-gU", str(binary))
    require("_gamecenter_library_init" in symbols, f"entry symbol missing from {binary.name}")


def inspect_macos_binary(binary: Path) -> None:
    description = run("file", str(binary))
    require("Mach-O universal binary" in description, f"not a universal Mach-O: {binary.name}")
    architectures = set(run("lipo", "-archs", str(binary)).split())
    require(architectures == {"arm64", "x86_64"}, f"unexpected macOS architectures: {architectures}")
    inspect_symbol(binary)
    build = run("vtool", "-show-build", str(binary))
    require("platform MACOS" in build, f"macOS platform metadata missing: {binary.name}")
    minimums = set(re.findall(r"\bminos\s+([0-9.]+)", build))
    require(minimums == {"11.0"}, f"unexpected macOS deployment target: {minimums}")


def inspect_ios_archive(binary: Path, expected_architectures: set[str], platform: str) -> None:
    description = run("file", str(binary))
    require("current ar archive" in description, f"not a static archive: {binary.name}")
    architectures = set(run("lipo", "-archs", str(binary)).split())
    require(
        architectures == expected_architectures,
        f"unexpected {platform} architectures: {architectures}",
    )
    inspect_symbol(binary)

    with tempfile.TemporaryDirectory(prefix="gamecenter-archive-") as directory:
        work_dir = Path(directory)
        for architecture in sorted(expected_architectures):
            thin_archive = binary
            if len(expected_architectures) > 1:
                thin_archive = work_dir / f"{architecture}.a"
                run("lipo", str(binary), "-thin", architecture, "-output", str(thin_archive))

            object_dir = work_dir / architecture
            object_dir.mkdir()
            run("ar", "-x", str(thin_archive), cwd=object_dir)
            objects = sorted(object_dir.glob("game_center_kit*.o"))
            require(len(objects) == 1, f"expected one GameCenterKit object in {binary.name}")
            build = run("vtool", "-show-build", str(objects[0]))
            require(f"platform {platform}" in build, f"{platform} metadata missing: {binary.name}")
            minimums = set(re.findall(r"\bminos\s+([0-9.]+)", build))
            require(minimums == {"14.0"}, f"unexpected iOS deployment target: {minimums}")


def inspect_xcframework(root: Path) -> None:
    info_path = root / "Info.plist"
    require(info_path.is_file(), "XCFramework Info.plist is missing")
    info = json.loads(run("plutil", "-convert", "json", "-o", "-", str(info_path)))
    libraries = info.get("AvailableLibraries", [])
    require(len(libraries) == 2, "XCFramework must contain device and simulator slices")

    found_device = False
    found_simulator = False
    for library in libraries:
        identifier = library["LibraryIdentifier"]
        binary = root / identifier / library["LibraryPath"]
        require(binary.is_file(), f"XCFramework binary is missing: {identifier}")
        architectures = set(library.get("SupportedArchitectures", []))
        require(library.get("SupportedPlatform") == "ios", f"unexpected platform: {identifier}")
        if library.get("SupportedPlatformVariant") == "simulator":
            require(not found_simulator, "duplicate simulator slice")
            require(architectures == {"arm64", "x86_64"}, "simulator slice must be universal")
            inspect_ios_archive(binary, architectures, "IOSSIMULATOR")
            found_simulator = True
        else:
            require(not found_device, "duplicate device slice")
            require(architectures == {"arm64"}, "device slice must be arm64")
            inspect_ios_archive(binary, architectures, "IOS")
            found_device = True
    require(found_device and found_simulator, "XCFramework is missing a required Apple slice")


def validate(archive: Path) -> None:
    require(archive.is_file(), f"archive does not exist: {archive}")
    with ZipFile(archive) as package:
        names = {entry.filename for entry in package.infolist()}
        require(names, "archive is empty")
        for name in names:
            path = PurePosixPath(name)
            require(not path.is_absolute() and ".." not in path.parts, f"unsafe archive path: {name}")
            require(name.startswith(ADDON_ROOT), f"entry is outside {ADDON_ROOT}: {name}")

        for required in ("README.md", "LICENSE", "plugin.cfg", "plugin.gd"):
            require_entry(names, required)

        extension = package.read(ADDON_ROOT + "gamecenter.gdextension").decode("utf-8")
        library_paths = set(re.findall(r'"res://addons/gamecenter/([^\"]+)"', extension))
        require(library_paths, "GDExtension declares no libraries")
        for library_path in library_paths:
            require_entry(names, library_path)

        parser = configparser.ConfigParser(interpolation=None)
        parser.read_string(package.read(ADDON_ROOT + "plugin.cfg").decode("utf-8"))
        version = parser.get("plugin", "version", fallback="").strip().strip('"')
        require(re.fullmatch(r"\d+\.\d+\.\d+", version) is not None, "plug-in version is not semantic")
        require(version == EXPECTED_VERSION, f"expected version {EXPECTED_VERSION}, found {version}")

        with tempfile.TemporaryDirectory(prefix="gamecenter-release-") as directory:
            extract_root = Path(directory)
            package.extractall(extract_root)
            addon = extract_root / ADDON_ROOT
            inspect_xcframework(addon / "bin/libgamecenter.ios.xcframework")
            inspect_macos_binary(addon / "bin/libgamecenter.macos.template_debug.universal.dylib")
            inspect_macos_binary(addon / "bin/libgamecenter.macos.template_release.universal.dylib")

    print(
        "validated GameCenterKit 1.0.0: iOS 14 arm64 device, "
        "arm64/x86_64 simulator, macOS 11 arm64/x86_64"
    )


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: validate_release.py <gamecenter-addon.zip>")
    try:
        validate(Path(sys.argv[1]).resolve())
    except (OSError, ValidationError, KeyError, ValueError) as error:
        raise SystemExit(f"release validation failed: {error}") from error
