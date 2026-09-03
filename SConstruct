#!/usr/bin/env python
# Builds the GameCenterKit GDExtension.
#   scons platform=macos target=template_debug     (editor/dev testing; GameKit exists on macOS)
#   scons platform=ios target=template_release arch=arm64
#   scons platform=ios target=template_release ios_simulator=yes arch=universal
import os

env = SConscript("godot-cpp/SConstruct")
env.Append(CPPPATH=["src/"])

sources = Glob("src/*.cpp")
if env["platform"] in ("ios", "macos"):
    sources += Glob("src/*.mm")
    env.Append(LINKFLAGS=["-framework", "GameKit", "-framework", "Foundation"])
    env.Append(CCFLAGS=["-fobjc-arc"])

# The addon under the example project is the single source of truth; the
# .gdextension there points at these paths. iOS static libs are intermediates
# (tools/build_xcframework.sh folds them into the shipped xcframework).
addon_bin = "example/addons/gamecenter/bin"

if env["platform"] == "ios":
    lib = env.StaticLibrary(
        "build/libgamecenter{}{}".format(env["suffix"], env["LIBSUFFIX"]),
        source=sources,
    )
else:
    lib = env.SharedLibrary(
        "{}/libgamecenter{}{}".format(addon_bin, env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )
Default(lib)
