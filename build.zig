const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    const exe = b.addExecutable(.{
        .name = "rayman",
        .root_module = module,
    });
    exe.entry = .disabled;
    exe.rdynamic = true;

    b.installArtifact(exe);

    // Creates a step for unit testing.
    const lib_unit_tests = b.addTest(.{
        .root_module = module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
