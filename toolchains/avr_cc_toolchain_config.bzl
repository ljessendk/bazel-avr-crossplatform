"""
Macros for setting up AVR C/C++ toolchains
"""

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "artifact_name_pattern",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path",
    "with_feature_set",
)

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

all_compile_actions = [
    ACTION_NAMES.assemble,
    ACTION_NAMES.c_compile,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.lto_backend,
    ACTION_NAMES.preprocess_assemble,
]

c_compile_actions = [
    ACTION_NAMES.c_compile,
]

cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
]

artifact_name_patterns = [
    artifact_name_pattern(
        category_name = "executable",
        prefix = "",
        extension = ".obj",
    ),
]

def _get_tool_paths(base):
    return [
        tool_path(
            name = "ar",
            path = base + "ar",
        ),
        tool_path(
            name = "cpp",
            path = base + "cpp",
        ),
        tool_path(
            name = "gcc",
            path = base + "gcc",
        ),
        tool_path(
            name = "gcov",
            path = base + "gcov",
        ),
        tool_path(
            name = "ld",
            path = base + "ld",
        ),
        tool_path(
            name = "nm",
            path = base + "nm",
        ),
        tool_path(
            name = "objdump",
            path = base + "objdump",
        ),
        tool_path(
            name = "strip",
            path = base + "strip",
        ),
        tool_path(
            name = "objcopy",
            path = base + "objcopy",
        ),
    ]

def _impl(ctx):
    # Unfortunately 'tool_path' doesn't accept labels: https://github.com/bazelbuild/bazel/issues/8438, 'tool_path' only accepts absolute paths and paths 'relative to the cc_toolchain's package'.
    # To workaround this we get the relative file path of the label (using ctx.files....path) and use this as the path 'relative to the cc_toolchain's package'. Unfortunately when using paths 'relative to the cc_toolchain's package' Bazel prefixes the path with the source path relative to the workspace root.
    # this means that you can only add toolchains from the root of the workspace :-(
    tool_paths = _get_tool_paths(ctx.files.toolchain_files[0].path + "/bin/avr-")

    features = [
        feature(
            name = "common",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-flto",
                                "-DF_CPU={}".format(ctx.attr.freq),
                                "-mmcu={}".format(ctx.attr.mmcu),
                                "-no-canonical-prefixes",
                                "-fno-canonical-system-headers",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = cpp_compile_actions,
                    flag_groups = [
                        flag_group(
                            flags = [
                                "-std=c++17",
                            ],
                        ),
                    ],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = [
                                "-flto",
                                "-fuse-linker-plugin",
                                "-mmcu={}".format(ctx.attr.mmcu),
                            ],
                        ),
                    ]),
                ),
            ],
        ),
        feature(
            name = "debug",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = ([
                        flag_group(
                            flags = ["-g", "-DDEBUG"],
                        ),
                    ]),
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = ["-g"],
                        ),
                    ]),
                    with_features = [with_feature_set(features = ["dbg"])],
                ),
            ],
        ),
        feature(
            name = "optimized",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = ([
                        flag_group(
                            flags = ["-O2", "-DNDEBUG"],
                        ),
                    ]),
                    with_features = [with_feature_set(features = ["opt"])],
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([
                        flag_group(
                            flags = ["-O2"],
                        ),
                    ]),
                    with_features = [with_feature_set(features = ["opt"])],
                ),
            ],
        ),
        feature(name = "dbg"),
        feature(name = "opt"),
        # Collecting code coverage on the AVR is currently not possible in our setup, so we disable this to avoid compiler errors
        feature(
            name = "coverage",
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = all_compile_actions,
                    flag_groups = ([]),
                ),
                flag_set(
                    actions = all_link_actions,
                    flag_groups = ([]),
                ),
            ],
        ),
    ]

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        features = features,
        toolchain_identifier = "avr",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "avr",
        target_libc = "unknown",
        compiler = "gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    attrs = {
        "toolchain_files": attr.label(cfg = "exec"),
        "mmcu": attr.string(mandatory = True),
        "freq": attr.int(mandatory = True),
    },
    provides = [CcToolchainConfigInfo],
)

def add_avr_cc_toolchain(name, mmcu, freq):
    """ Add AVR C/C++ toolchain

    Args:
        name: name of toolchain (example: "avr-at90can128_12mhz")
        mmcu: AVR MCU (example: at90can128)
        freq: CPU operating speed in Hz (example: 12000000)
    """

    toolchain_files = "//toolchains/crosscompilers:avr_fg"
    if native.existing_rule("empty") == None:
        native.filegroup(name = "empty")

    cc_toolchain_config(
        name = name + "-cc_toolchain_config",
        toolchain_files = toolchain_files,
        mmcu = mmcu,
        freq = freq,
    )

    native.cc_toolchain(
        name = name + "-cc_toolchain",
        toolchain_identifier = name + "-cc_toolchain",
        toolchain_config = name + "-cc_toolchain_config",
        all_files = toolchain_files,
        compiler_files = toolchain_files,
        dwp_files = ":empty",
        linker_files = toolchain_files,
        objcopy_files = toolchain_files,
        strip_files = toolchain_files,
        ar_files = toolchain_files,
        supports_param_files = 0,
        tags = ["manual"],
        visibility = ["//visibility:public"],
    )

    target_compatible_with = [
        "//platforms:avr",
        "//platforms:" + mmcu,
        "//platforms:" + str(freq) + "hz",
    ]

    native.toolchain(
        name = name + "_toolchain",
        target_compatible_with = target_compatible_with,
        toolchain = name + "-cc_toolchain",
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        tags = ["manual"],
    )
