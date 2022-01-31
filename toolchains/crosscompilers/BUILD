load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")
load("crosstoolng.bzl", "crosstoolng")

configure_make(
    name = "crosstool-ng",
    args = ["-j4 -l4"],
    lib_source = "@crosstool-ng//:srcs",
    out_binaries = ["ct-ng"],
    out_data_dirs = [
        "share",
        "libexec",
    ],
    tags = [
        # Tagged as manual to prevent build for target
        "manual",
    ],
)

filegroup(
    name = "ct-ng",
    srcs = [":crosstool-ng"],
    output_group = "ct-ng",
    tags = ["manual"],
)

filegroup(
    name = "lib_source",
    srcs = [
        "avr/defconfig",
        "crosstool-ng",
        "ct-ng",
    ],
    tags = ["manual"],
)

crosstoolng(
    name = "avr-toolchain",
    ct_ng = "ct-ng",
    defconfig = "avr/defconfig",
    out_binaries = [
        "avr-objcopy",
        "avr-objdump",
    ],
    tags = ["manual"],
    tarballs = ["@{}//file".format(d) for d in [
        "zlib-1.2.11",
        "gmp-6.1.2",
        "mpfr-3.1.6",
        "isl-0.18",
        "mpc-1.0.3",
        "libiconv-1.15",
        "binutils-2.30",
        "gcc-7.4.0",
        "avr-libc-2.0.0",
    ]],
    deps = [
        "crosstool-ng",
    ],
)

filegroup(
    name = "avr_fg",
    srcs = [
        "avr-toolchain",
    ],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)
