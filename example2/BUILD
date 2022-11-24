load("transitions.bzl", "cc_binary_platforms", "objcopy_platforms", "host_symlink_transition")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("genheader.bzl", "genheader")

[
    cc_binary_platforms(
        name = name,
        srcs = [
            "hello.cpp",
            "hello.h",
        ],
        includes = ["."],
        platforms = platforms,
    )
    for (platforms, name) in [
        ("//platforms:at90can128_12mhz", "helloworld_at90can128_12mhz"),
        ("//platforms:atmega328p_16mhz", "helloworld_atmega328p_16mhz"),
        ("", "helloworld"),
    ]
]

[
    objcopy_platforms(
        name = "%s.hex_rule" % name,
        src = "%s" % name,
        out = "%s.hex" % name,
        args = "-R .eeprom -O ihex",
        # Must be added otherwise hex files are build for both target and host (for some reason)
        target_compatible_with = ["//platforms:avr"],
        platforms = platforms,
    )
    for (platforms, name) in [
        ("//platforms:at90can128_12mhz", "helloworld_at90can128_12mhz"),
        ("//platforms:atmega328p_16mhz", "helloworld_atmega328p_16mhz"),
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
