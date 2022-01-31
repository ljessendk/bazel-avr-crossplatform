package(default_visibility = ["//visibility:public"])

constraint_setting(name = "cpu_variant")

constraint_value(
    name = "avr",
    constraint_setting = "@platforms//cpu:cpu",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "at90can128",
    constraint_setting = ":cpu_variant",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "atmega328p",
    constraint_setting = ":cpu_variant",
    visibility = ["//visibility:public"],
)

constraint_setting(name = "cpu_speed")

constraint_value(
    name = "12000000hz",
    constraint_setting = ":cpu_speed",
    visibility = ["//visibility:public"],
)

constraint_value(
    name = "16000000hz",
    constraint_setting = ":cpu_speed",
    visibility = ["//visibility:public"],
)

platform(
    name = "at90can128_12mhz",
    constraint_values = [
        ":avr",
        ":at90can128",
        ":12000000hz",
    ],
)

platform(
    name = "atmega328p_16mhz",
    constraint_values = [
        ":avr",
        ":atmega328p",
        ":16000000hz",
    ],
)
