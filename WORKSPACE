load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

http_archive(
    name = "rules_pkg",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz",
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz",
    ],
    sha256 = "8a298e832762eda1830597d64fe7db58178aa84cd5926d76d5b744d6558941c2",
)
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

http_archive(
    name = "rules_foreign_cc",
    sha256 = "bcd0c5f46a49b85b384906daae41d277b3dc0ff27c7c752cc51e43048a58ec83",
    strip_prefix = "rules_foreign_cc-0.7.1",
    url = "https://github.com/bazelbuild/rules_foreign_cc/archive/0.7.1.tar.gz",
)

http_archive(
    name = "crosstool-ng",
    build_file_content = "filegroup(name = 'srcs', srcs = glob(['**']), visibility = ['//visibility:public'])",
    sha256 = "d200d1ea5e2056c60d2b11b3f2721d30e53e817e1e0050fffaca074864e2f523",
    strip_prefix = "crosstool-ng-1.24.0",
    url = "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.bz2",
    patches = ["//toolchains/crosscompilers:crosstool-ng.patch"],
)

crosstool_ng_deps = [
    # AVR
    (
        "zlib-1.2.11",
        "zlib-1.2.11.tar.xz",
        "4ff941449631ace0d4d203e3483be9dbc9da454084111f97ea0a2114e19bf066",
        ["https://sourceforge.net/projects/libpng/files/zlib/1.2.11/"],
    ),
    (
        "gmp-6.1.2",
        "gmp-6.1.2.tar.xz",
        "87b565e89a9a684fe4ebeeddb8399dce2599f9c9049854ca8c0dfbdea0e21912",
        [
            "https://gmplib.org/download/gmp/",
            "https://gmplib.org/download/gmp/archive/",
        ],
    ),
    (
        "mpfr-3.1.6",
        "mpfr-3.1.6.tar.xz",
        "7a62ac1a04408614fccdc506e4844b10cf0ad2c2b1677097f8f35d3a1344a950",
        ["https://www.mpfr.org/mpfr-3.1.6/"],
    ),
    (
        "isl-0.18",
        "isl-0.18.tar.xz",
        "0f35051cc030b87c673ac1f187de40e386a1482a0cfdf2c552dd6031b307ddc4",
        ["https://libisl.sourceforge.io/"],
    ),
    (
        "mpc-1.0.3",
        "mpc-1.0.3.tar.gz",
        "617decc6ea09889fb08ede330917a00b16809b8db88c29c31bfbb49cbf88ecc3",
        ["https://ftp.gnu.org/gnu/mpc/"],
    ),
    (
        "libiconv-1.15",
        "libiconv-1.15.tar.gz",
        "ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178",
        [
            "https://ftpmirror.gnu.org/gnu/libiconv/",
            "http://ftpmirror.gnu.org/gnu/libiconv/",
            "https://ftp.gnu.org/gnu/libiconv/",
            "http://ftp.gnu.org/gnu/libiconv/",
        ],
    ),
    (
        "binutils-2.30",
        "binutils-2.30.tar.xz",
        "6e46b8aeae2f727a36f0bd9505e405768a72218f1796f0d09757d45209871ae6",
        [
            "https://ftpmirror.gnu.org/gnu/binutils/",
            "http://ftpmirror.gnu.org/gnu/binutils/",
            "https://ftp.gnu.org/gnu/binutils/",
            "http://ftp.gnu.org/gnu/binutils/",
            "http://mirrors.kernel.org/sourceware/binutils/releases",
            "http://gcc.gnu.org/pub/binutils/releases",
        ],
    ),
    (
        "gcc-7.4.0",
        "gcc-7.4.0.tar.xz",
        "eddde28d04f334aec1604456e536416549e9b1aa137fc69204e65eb0c009fe51",
        [
            "https://ftpmirror.gnu.org/gnu/gcc/gcc-7.4.0/",
            "http://ftpmirror.gnu.org/gnu/gcc/gcc-7.4.0/",
            "https://ftp.gnu.org/gnu/gcc/gcc-7.4.0/",
            "http://ftp.gnu.org/gnu/gcc/gcc-7.4.0/",
            "http://mirrors.kernel.org/sourceware/gcc/releases/gcc-7.4.0/",
            "http://gcc.gnu.org/pub/gcc/releases/gcc-7.4.0",
        ],
    ),
    (
        "avr-libc-2.0.0",
        "avr-libc-2.0.0.tar.bz2",
        "b2dd7fd2eefd8d8646ef6a325f6f0665537e2f604ed02828ced748d49dc85b97",
        ["https://download.savannah.gnu.org/releases/avr-libc/"],
    ),
]

[
    http_file(
        name = d[0],
        downloaded_file_path = d[1],
        sha256 = d[2],
        urls = [x + d[1] for x in d[3]],
    )
    for d in crosstool_ng_deps
]

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies(register_built_tools = False)

# new_git_repository(
#     name = "simulavr",
#     commit = "32985f745c237bf8dcd2718235d01c8b1fb0491d",
#     remote = "https://git.savannah.nongnu.org/git/simulavr.git",
#     shallow_since = "1602019857 +0200",
#     build_file_content = "filegroup(name = 'srcs', srcs = glob(['**']), visibility = ['//visibility:public'])",
# )

register_toolchains("//:avr-at90can128_12mhz_toolchain", "//:avr-atmega328p_16mhz_toolchain")

http_archive(
    name = "rules_cc",
    urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.1/rules_cc-0.0.1.tar.gz"],
    sha256 = "4dccbfd22c0def164c8f47458bd50e0c7148f3d92002cdb459c2a96a68498241",
)