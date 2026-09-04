# Godot Asset Store Listing Draft

## Asset name

GameCenterKit for Godot

## Summary

A focused, prebuilt, signal-driven Game Center bridge for Godot 4.5-4.7 on iOS 14+.

## Description

GameCenterKit connects a Godot game to Apple's Game Center through one small
GDExtension singleton. Authenticate the local player, submit leaderboard scores,
report achievement progress, present the native leaderboard and achievement panels,
and show or hide the Game Center access point.

Async GameKit operations answer through signals on Godot's main loop. The release
includes arm64 device and arm64/x86_64 simulator binaries plus universal macOS editor
binaries, so the add-on installs directly under `addons/gamecenter/` without requiring
consumers to compile native code.

Core 1.0 focuses on the common solo-game integration path. It does not include saved
games, friends, challenges, matchmaking, multiplayer, or turn-based matches.

## Features

- Local-player authentication and display name.
- Leaderboard score submission.
- Achievement progress from 0 through 100 percent.
- Native leaderboard and achievement panels on iOS/iPadOS.
- Game Center access point visibility.
- Main-loop result signals and deterministic input errors.
- Scene-aware panel presentation and shutdown-safe callbacks.
- Prebuilt Apple binaries and reproducible release validation.

## Compatibility fields

| Field | Value |
| --- | --- |
| Version | `1.0.0` |
| Minimum Godot | `4.5` |
| Maximum Godot | `4.7` |
| License | `MIT` |
| Runtime | iOS/iPadOS 14+ |
| Editor support | macOS 11+ |

## Tags

`iOS`, `Mobile`, `Apple`, `C++`, `GDExtension`

## Links

- Source: `https://github.com/keremvatandas/godot-ios-gamecenter` — pending repository
  publication.
- Support: `https://github.com/keremvatandas/godot-ios-gamecenter/issues` — pending
  repository publication.

## AI use disclosure — Store-required field

Codex assisted code review, test and CI design, documentation, and marketing-image
generation. The maintainer reviewed the resulting changes and validated GameKit
behavior.

## Optional proof line — exclude until explicitly approved

[GameCenterKit has been exercised in Gridlord during development.]
