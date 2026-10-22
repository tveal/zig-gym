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
                .keybinds_zoom = true, // Helps accessibility

                // Could set a default theme here
                // .theme = dvui.Theme.builtin.dracula,
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

    // Add your own bundled font files...:
    // try dvui.addFont("NOTO", @embedFile("../src/fonts/NotoSansKR-Regular.ttf"), null);

    // If you want a custom theme use something like this:
    // const theme = switch (win.backend.preferredColorScheme() orelse .light) {
    //     .light => dvui.Theme.builtin.adwaita_light,
    //     .dark => dvui.Theme.builtin.adwaita_dark,
    // };
    // win.themeSet(theme);
}

pub fn appDeinit(win: *dvui.Window) void {
    _ = win;
    // good place to free anything you've allocated with win.gpa
}
