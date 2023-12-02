const std = @import("std");
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
        var linePortions = std.mem.splitAny(u8, buffer.items, ":;");
        var game = std.mem.splitAny(u8, linePortions.next().?, " ");
        _ = game.next();
        const id = std.fmt.parseInt(u8, game.next().?, 10) catch |err| blk: {
            print("{any}", .{err});
            break :blk 0;
        };
        var failed = false;
        outer: while (linePortions.next()) |segment| {
            var cubes = std.mem.splitAny(u8, segment, ",");
            while (cubes.next()) |cube| {
                const trimmed = std.mem.trim(u8, cube, " ");
                var tmp = std.mem.splitAny(u8, trimmed, " ");
                var s = tmp.next().?;
                const value = std.fmt.parseInt(u8, s, 10) catch |err| {
                    print("{any}", .{err});
                    return;
                };
                const color = tmp.next().?;
                if (std.mem.eql(u8, color, "blue")) {
                    if (value > 14) {
                        failed = true;
                        break :outer;
                    }
                } else if (std.mem.eql(u8, color, "red")) {
                    if (value > 12) {
                        failed = true;
                        break :outer;
                    }
                } else if (std.mem.eql(u8, color, "green")) {
                    if (value > 13) {
                        failed = true;
                        break :outer;
                    }
                }
            }
        }
        if (!failed) {
            total += id;
        }
        if (done) {
            break;
        }
        buffer.clearRetainingCapacity();
    }
    print("Part One: {d}\n", .{total});
}
