const std = @import("std");
// https://ziglang.org/documentation/0.16.0/#Hello-World

pub fn main(init: std.process.Init) !void {
    try std.Io.File.stdout().writeStreamingAll(init.io, "Hello World!\n");
    // simpler log:
    std.debug.print("Another message from {s}.\n", .{"Zig"});
}
