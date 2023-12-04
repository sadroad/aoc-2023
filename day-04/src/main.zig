const std = @import("std");
const print = std.debug.print;

const Card = struct {
    number: u32,
    winningNumbers: std.AutoHashMap(u8, void),
    checkNumbers: []u8,
};

fn parseNumbers(list: *std.ArrayList(u8), numbers: []const u8) void {
    var split = std.mem.split(u8, numbers, " ");
    while (split.next()) |number| {
        if (number.len == 0) {
            continue;
        }
        const value = std.fmt.parseInt(u8, number, 10) catch |err| {
            print("{any}\n", .{err});
            return;
        };
        list.append(value) catch |err| {
            print("{any}\n", .{err});
            return;
        };
    }
}

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

    var cardQueue = std.ArrayList(Card).init(allocator);
    defer cardQueue.deinit();

    var cardMap = std.AutoHashMap(u32, Card).init(allocator);

    var validNumbers = std.ArrayList(u8).init(allocator);
    defer validNumbers.deinit();
    var checkNumbers = std.ArrayList(u8).init(allocator);
    defer checkNumbers.deinit();

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
        var gamePortion = std.mem.splitAny(u8, linePortions.next().?, " ");
        _ = gamePortion.next();
        var tmp = gamePortion.next().?;
        while (tmp.len == 0) {
            tmp = gamePortion.next().?;
        }
        const cardNumber = std.fmt.parseInt(u32, tmp, 10) catch |err| {
            print("{any}\n", .{err});
            return;
        };
        parseNumbers(&validNumbers, linePortions.next().?);
        parseNumbers(&checkNumbers, linePortions.next().?);
        var card = Card{ .number = cardNumber, .winningNumbers = std.AutoHashMap(u8, void).init(allocator), .checkNumbers = checkNumbers.toOwnedSlice() catch |err| {
            print("{any}\n", .{err});
            return;
        } };
        for (validNumbers.items) |number| {
            card.winningNumbers.put(number, {}) catch |err| {
                print("{any}\n", .{err});
                return;
            };
        }
        cardMap.put(cardNumber, card) catch |err| {
            print("{any}\n", .{err});
            return;
        };
        cardQueue.append(card) catch |err| {
            print("{any}\n", .{err});
            return;
        };
        if (done) {
            break;
        }
        validNumbers.clearRetainingCapacity();
        checkNumbers.clearRetainingCapacity();
        buffer.clearRetainingCapacity();
    }
    while (cardQueue.popOrNull()) |card| {
        // print("Card {d}\n ", .{card.number});
        var amountOfWinningNumbers: u8 = 0;
        for (card.checkNumbers) |check| {
            if (card.winningNumbers.get(check)) |_| {
                amountOfWinningNumbers += 1;
            }
        }
        if (amountOfWinningNumbers > 0) {
            for (1..amountOfWinningNumbers + 1) |i| {
                const storedNumber = card.number + @as(u32, @intCast(i));
                const storedCard = cardMap.get(storedNumber);
                if (storedCard == null) {
                    continue;
                }
                cardQueue.append(storedCard.?) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
            }
        }
        total += 1;
    }
    print("Part Two: {d}\n", .{total});
}
