# Bazel AVR cross-platform example

Example that shows the following:
- Bazel rules for building crosstool-ng (using foreign_rules_cc).
- Custom Bazel rule for building an AVR cross-compiler using crosstool-ng.
- Bazel macros for generating toolchain/cc_toolchain configuration's for specific AVR systems.
- Using the Bazel platforms API to select the correct toolchain.
- Using Bazel platform transitions to allow multi-platform builds.
- Proff-of-concept platform independent generated headers.
- Proff-of-concept at90can128_12mhz and atmega328p_16mhz platform definitions and examples.
- Example distribution package containing outputs for multiple platforms (using rules_pkg)
- Custom rules that use cc_toolchain.

Keywords: Bazel, multiplatform, crossplatform, transitions, toolchains, AVR, embedded, platform-independent

Usage:
bazel build ...

Note that building the cross-compiler may take up to ~30 mins.

## Examples

This repository contains 3 examples of different approaches to multiplatform builds using user-defined transitions:

### Example 1

Uses a custom 'platforms_transition_rule' that can transition a single file from a specific platform (specified using a 'platforms' argument) to the default target platform.

### Example 2

Uses 'rules_meta' to define static wrapper rules for each platform+rule combination.

### Example 3

Defines wrapper rules for existing rules. The new wrapper rules accepts a 'platforms' argument.
