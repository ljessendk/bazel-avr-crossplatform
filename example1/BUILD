load("transitions.bzl", "platforms_symlink_transition", "host_symlink_transition")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("genheader.bzl", "genheader")
load("//tools:objcopy.bzl", "objcopy")

cc_binary(
    name = "helloworld",
    srcs = [
        "hello.cpp",
        "hello.h",
    ],
    includes = ["."],
)

objcopy(
    name = "helloworld.hex_rule",
    src = "helloworld",
    out = "helloworld.hex",
    args = "-R .eeprom -O ihex",
    # Tagged as manual as we only want this to build if requested through a transition
    tags = ["manual"],
)

[
    platforms_symlink_transition(
        name = "%s_rule" % name,
        target_file = "helloworld",
        output = "%s" % name,
        platforms = platforms,
    )
    for (platforms, name) in [
        ("//platforms:at90can128_12mhz", "helloworld_at90can128_12mhz"),
        ("//platforms:atmega328p_16mhz", "helloworld_atmega328p_16mhz"),
    ]
]

[
    platforms_symlink_transition(
        name = "%s_rule" % name,
        target_file = "helloworld.hex",
        output = "%s" % name,
        platforms = platforms,
    )
    for (platforms, name) in [
        ("//platforms:at90can128_12mhz", "helloworld_at90can128_12mhz.hex"),
        ("//platforms:atmega328p_16mhz", "helloworld_atmega328p_16mhz.hex"),
    ]
]

cc_test(
    name = "helloworld_test",
    srcs = [
        "hello.cpp",
        "hello.h",
    ],
    includes = ["."],
)

genheader(
    name = "_hello.h",
    # Tagged as manual as we only want this to build if requested through a transition
    tags = ["manual"],
)

# Now we create a symlink transition hello.h -> hello.h (HOST)
host_symlink_transition(
    name = "hello.h_symlink",
    target_file = "_hello.h",
    output = "hello.h",
)

pkg_tar(
    name = "release",
    srcs = [
        "helloworld_at90can128_12mhz",
        "helloworld_at90can128_12mhz.hex",
        "helloworld_atmega328p_16mhz",
        "helloworld_atmega328p_16mhz.hex",
        "helloworld",
    ],
)
