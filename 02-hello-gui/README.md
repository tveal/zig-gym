# DVUI

David Vanderson UI - Immediate Zig GUI for Apps and Games

- [DVUI Website](https://david-vanderson.github.io/)
- [YouTube: Zig SHOWTIME #39 DVUI - David Vanderson](https://www.youtube.com/watch?v=B9dwuBXmTW0)

## Fast Start

```bash
zig build -l
zig build
zig build run
```

## Project Creation from Scratch

Setup zig runtime via mise:
```bash
mise use zig@0.17.0
```

Seed minimal zig project:
```bash
zig init -m
```

Refer to DVUI [Getting Started](https://github.com/david-vanderson/dvui#getting-started); Add DVUI as a dependency:
```bash
zig fetch --save git+https://github.com/david-vanderson/dvui#main
```

Edit `build.zig`, add the following to the build function:
```zig
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
```

Create `src/main.zig` with the initial content (not a GUI yet):
```zig
const std = @import("std");
const log = std.log;

pub fn main() !void {
    log.info("Hello, {s}!", .{"World"});
}
```

Build the project, pulling in `dvui` dependency (first time will take a while)
```bash
zig build
```

Run the app
```bash
zig build run
```

For an initial hello-world gui, change the `src/main.zig` to:
```zig
const dvui = @import("dvui");

pub const main = dvui.App.main;
pub const panic = dvui.App.panic;

pub const std_options: @import("std").Options = .{
    .logFn = dvui.App.logFn,
};

pub const dvui_app: dvui.App = .{
    .frameFn = appFrame,
    .initFn = appInit,
    .deinitFn = appDeinit,
    .config = .{
        .options = .{
            .title = "Zig DVUI App Example",
            .app = "hello-gui",
            .org = "zig-gym",
            .size = .{ .w = 800.0, .h = 600.0 },
            .min_size = .{ .w = 250.0, .h = 350.0 },
            .window_init_options = .{
                .keybinds_zoom = true,
            },
        },
    },
};

fn appFrame() !dvui.App.Result {
    dvui.label(@src(), "Hello, World!", .{}, .{});
    return .ok;
}

pub fn appInit(win: *dvui.Window) !void {
    _ = win.content_scale;
}

pub fn appDeinit(win: *dvui.Window) void {
    _ = win;
}
```

Test the app by running it:
```bash
zig build run
```

Now you're ready to start changing `src/main.zig` to be what you want.
Refer to [dvui-demo repo](https://github.com/david-vanderson/dvui-demo/tree/main) for source code to build a GUI app

NOTE: for neovim (lazyvim) LSP, if DVUI doesn't work, check LSP versions in `:Mason`

