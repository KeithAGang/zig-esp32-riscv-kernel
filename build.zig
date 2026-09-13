const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_features_add = std.Target.riscv.featureSet(&.{.c}),
        .cpu_features_sub = std.Target.riscv.featureSet(&.{ .d, .f }),
    });
    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .Debug,
    });
    kernel_mod.addAssemblyFile(b.path("src/kernel/boot.S"));

    const Chip = enum { virt, c3, p4 };
    const chip = b.option(Chip, "chip", "target chip") orelse .virt;

    const opts = b.addOptions();
    opts.addOption(Chip, "chip", chip);
    kernel_mod.addOptions("build_options", opts);

    const exe = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_mod,
    });
    exe.setLinkerScript(b.path("src/chip/virt/virt.ld"));
    exe.entry = .disabled;

    b.installArtifact(exe);

    const qemu = b.addSystemCommand(&.{
        "qemu-system-riscv32", "-machine", "virt",       "-m",      "8M",
        "-bios",               "none",     "-nographic", "-serial", "mon:stdio",
        "-kernel",
    });
    qemu.addArtifactArg(exe);
    const qemu_step = b.step("qemu", "Run kernel under QEMU virt");
    qemu_step.dependOn(&qemu.step);
}
