const std = @import("std");
const Io = std.Io;

pub fn main() !void {
    std.log.info("Hello {s}", .{"World!"});
    const i: u8 = 30;
    const base64 = Base64.init();
    std.log.info("Char at index {d}: {c}\n", .{i, base64.charAt(i)});
}

// -----
const Base64 = struct {
    table: *const [64]u8,
    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbersAndSymbols = "0123456789+/";
        return Base64 {
            .table = upper ++ lower ++ numbersAndSymbols,
        };
    }
    pub fn charAt(self: Base64, index: usize) u8 {
        return self.table[index];
    }
};
