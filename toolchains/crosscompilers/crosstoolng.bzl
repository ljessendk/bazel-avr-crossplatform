load("@rules_foreign_cc//toolchains/native_tools:tool_access.bzl", "get_make_data")

"""
Rules for building cross-compilers using crosstool-ng
"""

CrossCompilerToolchainInfo = provider(
    "Info about cross-compiler toolchain",
    fields = {
        "rootdir": "root directory",
    },
)

def _crosstoolng_impl(ctx):
    make_data = get_make_data(ctx)

    args = ctx.actions.args()
    args.add_all(ctx.files.tarballs)

    outdir = ctx.actions.declare_directory(ctx.attr.name)
    tarfile = ctx.outputs.tarfile
    ctx.actions.run_shell(
        outputs = [outdir] + ([tarfile] if tarfile != None else []),
        inputs = depset(ctx.files.deps, transitive = [make_data.target[DefaultInfo].files, depset(ctx.files.tarballs + [ctx.file.defconfig])]),
        arguments = [args],
        mnemonic = "CrossCompile",
        use_default_shell_env = True,
        command = "\n".join([
            """set -e -o pipefail""",
            """mkdir tarballs""",
            """cp $@ tarballs""",
            """cp {defconfig} defconfig""".format(defconfig = ctx.file.defconfig.path),
            # Fix defconfig
            """sed -i '/^CT_PREFIX_DIR/d' defconfig""",
            """echo CT_PREFIX_DIR=\\"{outdir}\\" >> defconfig""".format(outdir = outdir.path),
            """sed -i '/^CT_LOCAL_TARBALLS_DIR/d' defconfig""",
            """echo CT_LOCAL_TARBALLS_DIR=\\"tarballs\\" >> defconfig""",
            """sed -i '/^CT_FORBID_DOWNLOAD/d' defconfig""",
            """echo CT_FORBID_DOWNLOAD=y >> defconfig""",
            """{ct_ng} defconfig""".format(ct_ng = ctx.file.ct_ng.path),
            """{ct_ng} build""".format(ct_ng = ctx.file.ct_ng.path),
            """chmod -R u+w {outdir}""".format(outdir = outdir.path),
            # Delete bad symlinks
            """rm -rf {outdir}/share/licenses/crosstool-ng""".format(outdir = outdir.path),
            """tar cfz {tarfile} -C $(dirname {outdir}) $(basename {outdir})""".format(tarfile = tarfile.path, outdir = outdir.path) if tarfile != None else "",
        ]),
        progress_message = "Building cross-compiler - this can take a while...",
    )

    return [
        DefaultInfo(files = depset([outdir])),
        CrossCompilerToolchainInfo(
            rootdir = outdir,
        ),
    ]

crosstoolng = rule(
    implementation = _crosstoolng_impl,
    attrs = {
        "defconfig": attr.label(cfg = "exec", allow_single_file = ["defconfig"]),
        "ct_ng": attr.label(cfg = "exec", allow_single_file = True),
        "deps": attr.label_list(cfg = "exec", allow_files = True),
        "tarballs": attr.label_list(cfg = "exec", allow_files = True),
        "tarfile": attr.output(),
    },
    toolchains = ["@rules_foreign_cc//toolchains:make_toolchain"],
)
