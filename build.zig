const std = @import("std");
const idf_data = @import("main/paths.zig");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.esp32c3 },
        // ESP32-P4 has an FPU — tell Zig to use single-precision hard float
        // so the output matches ESP-IDF's -mabi=ilp32f object

    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig_app",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main/app.zig"),
            .target = target,
            .optimize = .ReleaseSmall,
            .link_libc = true,
        }),
    });

    lib.root_module.addCMacro("ESP_PLATFORM", "1");
    lib.root_module.addCMacro("__IEEE_LITTLE_ENDIAN", "1");
    lib.root_module.addCMacro("FORCE_INLINE_ATTR", "static inline");
    lib.root_module.addCMacro("__WINT_TYPE__", "unsigned int");
    lib.root_module.addCMacro("_WINT_T_DECLARED", "1");
    lib.root_module.addCMacro("wint_t", "unsigned int");
    lib.root_module.addCMacro("ESP_IDF_RISCV_COMPAT", "1");

    // These paths come from main/paths.zig, which is generated at build time
    // by generate_paths.py. Never hardcoded, never committed, always correct.
    lib.root_module.addIncludePath(.{ .cwd_relative = idf_data.newlib_include });
    lib.root_module.addIncludePath(.{ .cwd_relative = idf_data.newlib_platform });

    for (idf_data.include_paths) |path| {
        lib.root_module.addIncludePath(.{ .cwd_relative = path });
    }

    b.installArtifact(lib);
}
