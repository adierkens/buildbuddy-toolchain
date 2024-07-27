load("//:rules.bzl", "UBUNTU20_04_IMAGE", _buildbuddy = "buildbuddy")

_toolchain = tag_class(
    attrs = {
        "name": attr.string(mandatory = True),
        "container_image": attr.string(
            default = UBUNTU20_04_IMAGE,
        ),
        "llvm": attr.bool(
            default = False,
        ),
        "java_version": attr.string(
            default = "",
        ),
        "gcc_version": attr.string(
            default = "",
        ),
        "msvc_edition": attr.string(
            default = "Community",
        ),
        "msvc_release": attr.string(
            default = "2022",
        ),
        "msvc_version": attr.string(
            default = "14.39.33519",
        ),
        "windows_kits_release": attr.string(
            default = "10",
        ),
        "windows_kits_version": attr.string(
            default = "10.0.22621.0",
        ),
        "extra_cxx_builtin_include_directories": attr.string_list(
            default = [],
        ),
    },
)

def _buildbuddy_impl(mctx):
    toolchains = {}

    for mod in mctx.modules:
        for toolchain in mod.tags.toolchain:
            if not mctx.is_dev_dependency(toolchain):
                fail("Tag", toolchain, "is not dev dependency")

            if toolchain.name in toolchains:
                fail("Duplicate toolchain", toolchain.name)

            toolchains[toolchain.name] = toolchain

    for toolchain in toolchains.values():
        _buildbuddy(
            toolchain.name,
            container_image = toolchain.container_image,
            llvm = toolchain.llvm,
            java_version = toolchain.java_version,
            gcc_version = toolchain.gcc_version,
            msvc_edition = toolchain.msvc_edition,
            msvc_release = toolchain.msvc_release,
            msvc_version = toolchain.msvc_version,
            windows_kits_release = toolchain.windows_kits_release,
            windows_kits_version = toolchain.windows_kits_version,
            extra_cxx_builtin_include_directories = toolchain.extra_cxx_builtin_include_directories,
        )

    return mctx.extension_metadata(
        root_module_direct_deps = [],
        root_module_direct_dev_deps = "all",
        # reproducible = False,
    )

buildbuddy = module_extension(
    implementation = _buildbuddy_impl,
    tag_classes = {
        "toolchain": _toolchain,
    },
)
