const std = @import("std");

const AssetPackMapping = struct {
    input: []const u8,
    output: []const u8,
};

pub fn build(b: *std.Build) void {
    // Configure asset pack tool
    const asset_pack = b.addExecutable(.{
        .name = "asset_pack",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/asset_pack.zig"),
            .target = b.resolveTargetQuery(.{}),
        }),
    });

    const assets = [_]AssetPackMapping{
        .{
            .input = "assets/block.jpg",
            .output = "asset_block",
        },
    };
    var asset_outputs: [assets.len]std.Build.LazyPath = undefined;

    for (assets, 0..) |asset, idx| {
        const step = b.addRunArtifact(asset_pack);
        step.addFileArg(b.path(asset.input));
        asset_outputs[idx] = step.addOutputFileArg(asset.output);
    }

    // Target and module for wasm
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });

    // Map asset embeddings
    for (assets, 0..) |asset, idx| {
        module.addAnonymousImport(asset.output, .{
            .root_source_file = asset_outputs[idx],
        });
    }

    const exe = b.addExecutable(.{
        .name = "rayman",
        .root_module = module,
    });

    // Configure wasm specific things
    exe.entry = .disabled;
    exe.rdynamic = true;

    // Add wasm to install step
    b.installArtifact(exe);

    // Create a step for unit testing.
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    const lib_unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
