const std = @import("std");
const log = std.log;

pub fn main() !void {
    log.info("Hello {s}", .{"World!"});
    const i: u8 = 30;
    const base64 = Base64.init();
    log.info("Char at index {d}: {c}\n", .{ i, base64.charAt(i) });

    var memBuf: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memBuf);
    const allocator = fba.allocator();
    const text = "Learning things is fun!";

    const encodedText = try base64.encode(allocator, text);
    const decodedText = try base64.decode(allocator, encodedText);
    defer allocator.free(encodedText);
    defer allocator.free(decodedText);

    log.info("Encoded text: {s}", .{encodedText});
    log.info("Encoded length: {d}", .{encodedText.len});
    log.info("Decoded text: {s}", .{decodedText});
    log.info("Decoded length: {d}", .{decodedText.len});
}

test "encode 7 bytes does not have padding bug" {
    const gpa = std.testing.allocator;
    const text = "ABCDEFG";
    const base64 = Base64.init();

    const encodedText = try base64.encode(gpa, text);
    const decodedText = try base64.decode(gpa, encodedText);
    defer gpa.free(encodedText);
    defer gpa.free(decodedText);

    try std.testing.expectEqualStrings(decodedText, text);
    try std.testing.expectEqualStrings("QUJDREVGRw==", encodedText);
}

// ----- Base64 Logic -----
const Base64 = struct {
    table: *const [64]u8,
    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbersAndSymbols = "0123456789+/";
        return Base64{
            .table = upper ++ lower ++ numbersAndSymbols,
        };
    }
    pub fn charAt(self: Base64, index: usize) u8 {
        return self.table[index];
    }
    fn charIndex(self: Base64, char: u8) u8 {
        if (char == '=') return 64;
        var i: u8 = 0;
        var iout: u8 = 0;
        while (i < 64) : (i += 1) {
            if (self.charAt(i) == char) break;
            iout += 1;
        }
        return iout;
    }
    pub fn encode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 0) return "";
        const outLen = try calcEncodeLength(input);
        var out = try allocator.alloc(u8, outLen);
        var buf = [3]u8{ 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;
        for (input, 0..) |_, i| {
            buf[count] = input[i];
            count += 1;
            if (count == 3) {
                out[iout] = self.charAt(buf[0] >> 2);
                out[iout + 1] = self.charAt(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
                out[iout + 2] = self.charAt(((buf[1] & 0x0f) << 2) + (buf[2] >> 6));
                out[iout + 3] = self.charAt(buf[2] & 0x3f);
                iout += 4;
                count = 0;
            }
        }
        if (count == 1) {
            out[iout] = self.charAt(buf[0] >> 2);
            out[iout + 1] = self.charAt((buf[0] & 0x03) << 4);
            out[iout + 2] = '=';
            out[iout + 3] = '=';
        }
        if (count == 2) {
            out[iout] = self.charAt(buf[0] >> 2);
            out[iout + 1] = self.charAt(((buf[0] & 0x03) << 4) + (buf[1] >> 4));
            out[iout + 2] = self.charAt((buf[1] & 0x0f) << 2);
            out[iout + 3] = '=';
            iout += 4;
        }
        return out;
    }
    pub fn decode(
        self: Base64,
        allocator: std.mem.Allocator,
        input: []const u8,
    ) ![]u8 {
        if (input.len == 4) return "";
        const outLen = try calcDecodeLength(input);
        var out = try allocator.alloc(u8, outLen);
        @memset(out[0..], 0);
        var buf = [4]u8{ 0, 0, 0, 0 };
        var count: u8 = 0;
        var iout: u64 = 0;

        for (0..input.len) |i| {
            buf[count] = self.charIndex(input[i]);
            count += 1;
            if (count == 4) {
                out[iout] = (buf[0] << 2) + (buf[1] >> 4);
                if (buf[2] != 64) out[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
                if (buf[3] != 64) out[iout + 2] = (buf[2] << 6) + buf[3];
                iout += 3;
                count = 0;
            }
        }

        return out;
    }
};

fn calcEncodeLength(input: []const u8) !usize {
    if (input.len < 3) return 4;
    const groupCount: usize = try std.math.divCeil(usize, input.len, 3);
    return groupCount * 4;
}

fn calcDecodeLength(input: []const u8) !usize {
    if (input.len < 4) return 3;
    const groupCount: usize = try std.math.divFloor(usize, input.len, 4);
    var groupCountTrimmed: usize = groupCount * 3;
    var i: usize = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            groupCountTrimmed -= 1;
        } else {
            break;
        }
    }
    return groupCountTrimmed;
}
