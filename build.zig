const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .riscv32,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const kernel_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .Debug,
    });
    kernel_mod.addAssemblyFile(b.path("src/kernel/boot.S"));

    const exe = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_mod,
    });
    exe.setLinkerScript(b.path("src/chip/virt/virt.ld"));
    exe.entry = .disabled;

    b.installArtifact(exe);

    const qemu = b.addSystemCommand(&.{
        "qemu-system-riscv32", "-machine", "virt",       "-m",      "500K",
        "-bios",               "none",     "-nographic", "-kernel",
    });
    qemu.addArtifactArg(exe);
    const qemu_step = b.step("qemu", "Run kernel under QEMU virt");
    qemu_step.dependOn(&qemu.step);
}
