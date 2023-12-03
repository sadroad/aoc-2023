const std = @import("std");
const print = std.debug.print;

const PartNumber = struct { value: u32, length: usize, x: i32, y: i16 };
const Gear = struct { x: i32, y: i16 };

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

    var lineNumber: i16 = 0;

    var numAllocator = std.ArrayList(u8).init(allocator);
    defer numAllocator.deinit();

    var potentialParts = std.ArrayList(PartNumber).init(allocator);
    defer potentialParts.deinit();

    var parts = std.ArrayList(Gear).init(allocator);
    defer parts.deinit();

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

        for (buffer.items, 0..) |character, index| {
            if (std.ascii.isDigit(character)) {
                numAllocator.append(character) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
            } else if (numAllocator.items.len > 0) {
                const potentialNumber = PartNumber{ .value = std.fmt.parseInt(u32, numAllocator.items, 10) catch |err| {
                    print("{any}\n", .{err});
                    return;
                }, .length = numAllocator.items.len, .x = @as(i32, @intCast(index - numAllocator.items.len)), .y = lineNumber };
                potentialParts.append(potentialNumber) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
                numAllocator.clearRetainingCapacity();
            }
            if (numAllocator.items.len > 0 and buffer.items.len == index + 1) {
                const potentialNumber = PartNumber{ .value = std.fmt.parseInt(u32, numAllocator.items, 10) catch |err| {
                    print("{any}\n", .{err});
                    return;
                }, .length = numAllocator.items.len, .x = @as(i32, @intCast(index - numAllocator.items.len)), .y = lineNumber };
                potentialParts.append(potentialNumber) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
                numAllocator.clearRetainingCapacity();
            }
            if (character == '*') {
                parts.append(Gear{ .x = @as(i32, @intCast(index)), .y = lineNumber }) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
            }
        }

        if (done) {
            break;
        }
        lineNumber += 1;
        buffer.clearRetainingCapacity();
    }
    var potentialRatio = std.ArrayList(PartNumber).init(allocator);
    defer potentialRatio.deinit();
    for (parts.items) |part| {
        for (potentialParts.items) |potentialPart| {
            // print("{any}\n", .{parts.items});
            if (part.x > potentialPart.x - 2 and part.x < @as(i8, @intCast(potentialPart.length)) + potentialPart.x + 1 and part.y > potentialPart.y - 2 and part.y < potentialPart.y + 2) {
                potentialRatio.append(potentialPart) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
            }
        }
        if (potentialRatio.items.len == 2) {
            const ratio = potentialRatio.items[0].value * potentialRatio.items[1].value;
            total += ratio;
        }
        potentialRatio.clearRetainingCapacity();
    }
    print("Part Two: {d}\n", .{total});
}
