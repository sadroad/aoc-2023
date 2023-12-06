const std = @import("std");
const print = std.debug.print;
fn printNoArgs(comptime message: []const u8) void {
    std.debug.print(message, .{});
}

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const file = std.fs.cwd().openFile("input", .{ .mode = .read_only }) catch |err| {
        print("{any}\n", .{err});
        return;
    };
    defer file.close();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var total: u64 = 1;

    var time = std.ArrayList(u64).init(allocator);
    defer time.deinit();

    var distance = std.ArrayList(u64).init(allocator);
    defer distance.deinit();

    var line: usize = 0;

    while (true) {
        var done = false;
        while (true) {
            const byte = file.reader().readByte() catch |err| switch (err) {
                error.EndOfStream => {
                    done = true;
                    break;
                },
                else => |e| {
                    print("Error reading byte: {any}\n", .{e});
                    return;
                },
            };
            if (byte == '\n') {
                break;
            }
            buffer.append(byte) catch |err| {
                print("Error appending byte to buffer: {any}\n", .{err});
                return;
            };
        }
        if (buffer.items.len == 0 and !done) {
            continue;
        }

        var lineSections = std.mem.splitAny(u8, buffer.items, ":");
        _ = lineSections.next();
        var timings = std.mem.splitAny(u8, lineSections.next().?, " ");
        while (timings.next()) |t| {
            if (t.len == 0) {
                continue;
            }
            const v = std.fmt.parseInt(u64, t, 10) catch |err| {
                print("Error parsing int: {any}\n", .{err});
                return;
            };
            if (line == 0) {
                time.append(v) catch |err| {
                    print("Error appending time: {any}\n", .{err});
                    return;
                };
            } else {
                distance.append(v) catch |err| {
                    print("Error appending distance: {any}\n", .{err});
                    return;
                };
            }
        }

        if (done) {
            break;
        }
        line += 1;
        buffer.clearRetainingCapacity();
    }

    for (0..time.items.len) |i| {
        const t = time.items[i];
        const d = distance.items[i];
        var local: u64 = 0;
        for (0..t) |j| {
            if (j * (t - j) > d) {
                local += 1;
            }
        }
        total *= local;
    }

    print("Part One: {d}\n", .{total});
}
