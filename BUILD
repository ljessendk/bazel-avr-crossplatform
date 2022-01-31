load("//toolchains:avr_cc_toolchain_config.bzl", "add_avr_cc_toolchain")

# Toolchain's must be added in the root folder of the workspace, otherwise tool_path lookup will fail.
add_avr_cc_toolchain(
    name = "avr-at90can128_12mhz",
    mmcu = "at90can128",
    freq = 12000000,
)

add_avr_cc_toolchain(
    name = "avr-atmega328p_16mhz",
    mmcu = "atmega328p",
    freq = 16000000,
)
