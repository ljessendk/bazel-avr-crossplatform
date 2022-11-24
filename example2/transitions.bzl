"""
Methods for performing platform transitions
"""
load("//tools:objcopy.bzl", "objcopy")

def cc_binary_platforms(name, platforms = "", tags = [], **kwargs):
    """
    cc_binary with platform transition

    Args:
        name: rule name
        tags: tags
        platforms: platform to use
        **kwargs: additional arguments passed to objcopy
    """
    if platforms != "":
        orig_name = name + ".orig"
        internal_rule_tags = tags + (["manual"] if "manual" not in tags else [])
        native.cc_binary(name = orig_name, tags = internal_rule_tags, **kwargs)
        platforms_symlink_transition(
            name = name + "_transition_rule",
            platforms = platforms,
            target_file = orig_name,
            output = name
        )
    else:
        native.cc_binary(name = name, tags = tags, **kwargs)

def objcopy_platforms(name, out, platforms = "", tags = [], **kwargs):
    """
    objcopy with platform transition

    Args:
        name: rule name
        out: output
        tags: tags
        platforms: platform to use
        **kwargs: additional arguments passed to objcopy
    """
    if platforms != "":
        orig_name = name + ".orig"
        orig_out = out + ".orig"
        internal_rule_tags = tags + (["manual"] if "manual" not in tags else [])
        objcopy(name = orig_name, out = orig_out, tags = internal_rule_tags, **kwargs)
        platforms_symlink_transition(
            name = name + "_transition_rule",
            platforms = platforms,
            target_file = orig_out,
            output = out
        )
    else:
        objcopy(name = name, tags= tags, **kwargs)

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

_platforms_symlink_transition_attrs = _attrs(_platforms_transition)
_platforms_symlink_transition_attrs.update({
    # Platforms setting (override //command_line_option:platforms)
    "platforms": attr.string(),
    # Enable/allow user-defined transitions (see https://bazel.build/rules/config#user-defined-transitions)
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
})

platforms_symlink_transition = rule(
    implementation = _symlink_transition_rule_impl,
    attrs = _platforms_symlink_transition_attrs,
    executable = False,
)

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
