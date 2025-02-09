const std = @import("std");

const AssetPackMapping = struct {
    input: []const u8,
    output: []const u8,
};

pub fn build(b: *std.Build) void {
    // Target and optimize options
    const native_target = b.standardTargetOptions(.{});
    const default_optimize = b.standardOptimizeOption(.{});

    // Configure asset pack tool
    const asset_pack = b.addExecutable(.{
        .name = "asset_pack",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/asset_pack/main.zig"),
            .target = b.resolveTargetQuery(.{}),
        }),
    });
    asset_pack.addCSourceFile(.{
        .file = b.path("src/asset_pack/stb_image_impl.c"),
    });
    asset_pack.addIncludePath(b.path("src/asset_pack"));

    const assets = [_]AssetPackMapping{
        .{
            .input = "assets/tiles.png",
            .output = "tiles",
        },
        .{
            .input = "assets/font.png",
            .output = "font",
        },
        .{
            .input = "assets/coin.png",
            .output = "coin",
        },
        .{
            .input = "assets/key.png",
            .output = "key",
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

    // Module for testing
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = native_target,
        .optimize = default_optimize,
    });

    // Module for testing how map generation works
    const map_gen_module = b.createModule(.{
        .root_source_file = b.path("src/map_gen.zig"),
        .target = native_target,
        .optimize = default_optimize,
    });

    // Map asset embeddings
    for (assets, 0..) |asset, idx| {
        module.addAnonymousImport(asset.output, .{
            .root_source_file = asset_outputs[idx],
        });

        test_module.addAnonymousImport(asset.output, .{
            .root_source_file = asset_outputs[idx],
        });

        map_gen_module.addAnonymousImport(asset.output, .{
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

    // Create a step to test map generation
    const map_gen = b.addExecutable(.{
        .name = "rayman-map-gen",
        .root_module = map_gen_module,
    });

    const run_map_gen = b.addRunArtifact(map_gen);

    const map_gen_step = b.step("map-gen", "Run map generation display");
    map_gen_step.dependOn(&run_map_gen.step);

    // Create a step for unit testing.
    const lib_unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
