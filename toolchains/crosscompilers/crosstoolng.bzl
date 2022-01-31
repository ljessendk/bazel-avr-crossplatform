"""
Rules for building cross-compilers using crosstool-ng
"""

# ***** Begin: From rules_foreign_cc, framework.bzl

def _declare_out(ctx, lib_name, dir_, files):
    if files and len(files) > 0:
        return [ctx.actions.declare_file("/".join([lib_name, dir_, file])) for file in files]
    return []

def _declare_output_groups(outputs):
    dict_ = {}
    for output in outputs:
        dict_[output.basename] = [output]
    return dict_

# ***** End: From rules_foreign_cc, framework.bzl

CrossCompilerToolchainInfo = provider(
    "Info about cross-compiler toolchain",
    fields = {
        "rootdir": "root directory",
        "out_binary_files": "Binary files",
    },
)

def _crosstoolng_impl(ctx):
    out_binary_files = _declare_out(ctx, ctx.attr.name, ctx.attr.out_bin_dir, ctx.attr.out_binaries)
    args = ctx.actions.args()
    args.add_all(ctx.files.tarballs)

    outdir = ctx.actions.declare_directory(ctx.attr.name)
    tarfile = ctx.outputs.tarfile
    ctx.actions.run_shell(
        outputs = [outdir] + out_binary_files + ([tarfile] if tarfile != None else []),
        inputs = depset(ctx.files.deps, transitive = [depset(ctx.files.tarballs + [ctx.file.defconfig])]),
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
            """tar cfz {tarfile} -C $(dirname {outdir}) $(basename {outdir})""".format(tarfile = tarfile.path, outdir = outdir.path) if tarfile != None else "",
        ]),
        progress_message = "Building cross-compiler - this can take a while...",
    )

    output_groups = _declare_output_groups(out_binary_files)

    return [
        DefaultInfo(files = depset([outdir])),
        OutputGroupInfo(**output_groups),
        CrossCompilerToolchainInfo(
            rootdir = outdir,
            out_binary_files = out_binary_files,
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
        "out_bin_dir": attr.string(default = "bin"),
        "out_binaries": attr.string_list(),
    },
)
