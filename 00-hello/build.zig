const std = @import("std");

fn hello(_: *std.Build.Step, _: std.Build.Step.MakeOptions) !void {
    std.debug.print("Hello, world!\nFrom the build.zig config.\n", .{});
}

pub fn build(buildGraph: *std.Build) void {
    const hello_step = buildGraph.step("hello", "Say hello");
    hello_step.makeFn = hello;

    const target = buildGraph.standardTargetOptions(.{});
    const optimize = buildGraph.standardOptimizeOption(.{});

    const mod = buildGraph.addModule("hello", .{
        .root_source_file = buildGraph.path("src/root.zig"),
        .target = target,
    });

    const exe = buildGraph.addExecutable(.{
        .name = "hello",
        .root_module = buildGraph.createModule(.{
            .root_source_file = buildGraph.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "hello", .module = mod },
            },
        }),
    });
    buildGraph.installArtifact(exe);

    const run_step = buildGraph.step("run", "Run the app");
    const run_cmd = buildGraph.addRunArtifact(exe);

    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(buildGraph.getInstallStep());

    if (buildGraph.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = buildGraph.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = buildGraph.addRunArtifact(mod_tests);
    const exe_tests = buildGraph.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = buildGraph.addRunArtifact(exe_tests);
    const test_step = buildGraph.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
