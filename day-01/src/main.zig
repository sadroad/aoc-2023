const std = @import("std");
const isDigit = std.ascii.isDigit;
const print = std.debug.print;

const map = std.ComptimeStringMap(u8, .{
    .{ "one", 1 },
    .{ "two", 2 },
    .{ "three", 3 },
    .{ "four", 4 },
    .{ "five", 5 },
    .{ "six", 6 },
    .{ "seven", 7 },
    .{ "eight", 8 },
    .{ "nine", 9 },
});

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    var allocator = gpa.allocator();
    const file = std.fs.cwd().openFile("input", .{ .mode = .read_only }) catch |err| {
        print("{any}", .{err});
        return;
    };
    defer file.close();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var total: u32 = 0;

    var first: ?u8 = null;
    var last: u8 = 0;

    while (true) {
        var done = false;
        while (true) {
            const byte = file.reader().readByte() catch |err| switch (err) {
                error.EndOfStream => {
                    done = true;
                    break;
                },
                else => |e| {
                    print("{any}", .{e});
                    return;
                },
            };
            if (byte == '\n') {
                break;
            }
            buffer.append(byte) catch |err| {
                print("{any}", .{err});
                return;
            };
        }
        var i: u8 = 0;
        while (i < buffer.items.len) {
            defer i += 1;
            const character = buffer.items[i];
            if (isDigit(character)) {
                if (first == null) {
                    first = character - '0';
                }
                last = character - '0';
            } else {
                if (buffer.items.len < 3) {
                    continue;
                }
                for (map.kvs) |pair| {
                    const key = pair.key;
                    const value = pair.value;
                    if (buffer.items.len < i + key.len) {
                        continue;
                    }
                    const fragment = buffer.items[i .. i + key.len];
                    if (std.mem.eql(u8, fragment, key)) {
                        if (first == null) {
                            first = value;
                        }
                        last = value;
                        i += @as(u8, @intCast(key.len - 2));
                    }
                }
            }
        }
        if (first) |v| {
            total += (v * 10) + last;
        }
        if (done) {
            break;
        }
        first = null;
        last = 0;
        buffer.clearRetainingCapacity();
    }
    print("Part Two: {d}\n", .{total});
}
