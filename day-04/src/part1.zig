const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    var allocator = gpa.allocator();
    const file = std.fs.cwd().openFile("input", .{ .mode = .read_only }) catch |err| {
        print("{any}\n", .{err});
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
                    print("{any}\n", .{e});
                    return;
                },
            };
            if (byte == '\n') {
                break;
            }
            buffer.append(byte) catch |err| {
                print("{any}\n", .{err});
                return;
            };
        }
        var linePortions = std.mem.splitAny(u8, buffer.items, ":|");
        var gamePortion = linePortions.next().?;
        _ = gamePortion;
        var winningNumbers = std.mem.splitAny(u8, linePortions.next().?, " ");
        var validNumbers = std.ArrayList(u8).init(allocator);
        defer validNumbers.deinit();
        while (winningNumbers.next()) |winningNumber| {
            if (winningNumber.len == 0) {
                continue;
            }
            const number = std.fmt.parseInt(u8, winningNumber, 10) catch |err| {
                print("{any}\n", .{err});
                return;
            };
            validNumbers.append(number) catch |err| {
                print("{any}\n", .{err});
                return;
            };
        }
        var testNumbers = std.mem.splitAny(u8, linePortions.next().?, " ");
        var checkNumbers = std.ArrayList(u8).init(allocator);
        defer checkNumbers.deinit();
        while (testNumbers.next()) |number| {
            if (number.len == 0) {
                continue;
            }
            const value = std.fmt.parseInt(u8, number, 10) catch |err| {
                print("{any}\n", .{err});
                return;
            };
            checkNumbers.append(value) catch |err| {
                print("{any}\n", .{err});
                return;
            };
        }
        var localTotal: u32 = 0;
        for (checkNumbers.items) |checkNumber| {
            for (validNumbers.items) |validNumber| {
                if (checkNumber == validNumber) {
                    if (localTotal == 0) {
                        localTotal = 1;
                    } else {
                        localTotal *= 2;
                    }
                    break;
                }
            }
        }
        total += localTotal;
        if (done) {
            break;
        }
        buffer.clearRetainingCapacity();
    }
    print("Part One: {d}\n", .{total});
}
