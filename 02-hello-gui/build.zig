const std = @import("std");

pub fn build(b: *std.Build) void {
    // exe setup
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello_gui",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    // run step
    const runStp = b.step("run", "Run the app");
    const runCmd = b.addRunArtifact(exe);
    runStp.dependOn(&runCmd.step);
    runCmd.step.dependOn(b.getInstallStep());
    runCmd.addPassthruArgs();

    // DEPENDENCIES
    // ------------
    // dvui
    const depDvui = b.dependency("dvui", .{ .target = target, .optimize = optimize, .backend = .sdl3 });
    exe.root_module.addImport("dvui", depDvui.module("dvui_sdl3"));
}
