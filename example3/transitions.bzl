"""
Methods for performing platform transitions
"""
load("//tools:objcopy.bzl", "objcopy")
load(":transition_wrap.bzl", "meta")

def _platforms_transition_impl(settings, attr):
    _ignore = settings

    res = {
        "//command_line_option:platforms": attr.platforms,
    } if attr.platforms != "" else {}

    return res

_platforms_transition = transition(
    implementation = _platforms_transition_impl,
    inputs = [
    ],
    outputs = [
        "//command_line_option:platforms",
    ],
)

_platforms_transition_rule = meta.create_transition_rule(
    _platforms_transition,
    attrs = {
        "platforms": attr.string()
    },
)

def cc_binary_platforms(*, name, platforms, **kwargs):
    meta.wrap_with_transition(native.cc_binary, _platforms_transition_rule, platforms = platforms)(name = name, platforms = platforms, **kwargs)

def objcopy_platforms(*, name, platforms, **kwargs):
    meta.wrap_with_transition(objcopy, _platforms_transition_rule, platforms = platforms)(name = name, platforms = platforms, **kwargs)

def _symlink_transition_rule_impl(ctx):
    ctx.actions.symlink(output = ctx.outputs.output, target_file = ctx.file.target_file)

    return [
        DefaultInfo(
            files = depset([ctx.outputs.output]),
        ),
    ]

def _attrs(cfg):
    return {
        # The output of this rule.
        "output": attr.output(mandatory = True),
        # The File that the output symlink will point to.
        "target_file": attr.label(mandatory = True, allow_single_file = True, cfg = cfg),
    }

def _create_symlink_transition_rule(cfg):
    return rule(
        implementation = _symlink_transition_rule_impl,
        attrs = _attrs(cfg),
        executable = False,
    )

host_symlink_transition = _create_symlink_transition_rule("host")

# Note: Use host_symlink_transition instead as currently, exec may have multiple transitions
# This is probably due to the issues mentioned here (https://github.com/bazelbuild/bazel/issues/13281, https://github.com/bazelbuild/bazel/issues/14023)
exec_symlink_transition = _create_symlink_transition_rule("exec")
