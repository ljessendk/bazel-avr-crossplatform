"""
Methods for performing platform transitions
"""

load("@rules_meta//meta:defs.bzl", "meta")
load("//tools:objcopy.bzl", "objcopy")

def _cc_binary(platforms):
    return meta.wrap_with_transition(
        native.cc_binary,
        {
            "platforms": meta.replace_with([platforms]),
        },
    )

at90can128_12mhz_cc_binary = _cc_binary("//platforms:at90can128_12mhz")
atmega328p_16mhz_cc_binary = _cc_binary("//platforms:atmega328p_16mhz")
host_cc_binary = _cc_binary("@local_config_platform//:host")

def _objcopy(platforms):
    return meta.wrap_with_transition(
        objcopy,
        {
            "platforms": meta.replace_with([platforms]),
        },
    )

at90can128_12mhz_objcopy = _objcopy("//platforms:at90can128_12mhz")
atmega328p_16mhz_objcopy = _objcopy("//platforms:atmega328p_16mhz")

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
