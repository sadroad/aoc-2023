const std = @import("std");
const isDigit = std.ascii.isDigit;
const print = std.debug.print;

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
        for (buffer.items) |character| {
            if (isDigit(character)) {
                if (first == null) {
                    first = character - '0';
                }
                last = character - '0';
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
    print("Part One: {d}\n", .{total});
}
