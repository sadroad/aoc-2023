const std = @import("std");
const print = std.debug.print;

const PartNumber = struct { value: u32, length: usize, x: i32, y: i16 };
const Part = struct { x: i32, y: i16 };

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

    var parts = std.ArrayList(Part).init(allocator);
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
                // print("{c}\n", .{character});
            } else if (numAllocator.items.len > 0) {
                // print("Index: {any}\n", .{index});
                // print("Length: {any}\n", .{numAllocator.items.len});
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
            if (character != '.' and !std.ascii.isDigit(character)) {
                parts.append(Part{ .x = @as(i32, @intCast(index)), .y = lineNumber }) catch |err| {
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
    for (potentialParts.items) |potentialPart| {
        // print("{any}\n", .{parts.items});
        for (parts.items) |part| {
            if (part.x > potentialPart.x - 2 and part.x < @as(i8, @intCast(potentialPart.length)) + potentialPart.x + 1 and part.y > potentialPart.y - 2 and part.y < potentialPart.y + 2) {
                total += potentialPart.value;
                break;
            }
        }
    }
    print("Part One: {d}\n", .{total});
}
