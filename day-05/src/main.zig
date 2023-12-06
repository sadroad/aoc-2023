const std = @import("std");
const print = std.debug.print;
fn printNoArgs(comptime message: []const u8) void {
    std.debug.print(message, .{});
}

const Range = struct {
    source: u64,
    destination: u64,
    range: u64,
    fn inSource(self: *const Range, value: u64) ?u64 {
        // print("In source: {d} {d} {d}\n", .{ self.source, self.destination, self.range });
        // print("Value: {d}\n", .{value});
        // print("First: {any}\n", .{value > self.source});
        // print("Second: {any}\n", .{value < self.source + self.range});
        if (value >= self.source and value < self.source + self.range) {
            return value - self.source + self.destination;
        }
        return null;
    }
};

const SeedRange = struct {
    start: u64,
    range: u64,
};

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const file = std.fs.cwd().openFile("input", .{ .mode = .read_only }) catch |err| {
        print("{any}\n", .{err});
        return;
    };
    defer file.close();

    var seeds = std.ArrayList(SeedRange).init(allocator);
    defer seeds.deinit();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    var seedToSoil = std.ArrayList(Range).init(allocator);
    defer seedToSoil.deinit();

    var soilToFertilizer = std.ArrayList(Range).init(allocator);
    defer soilToFertilizer.deinit();

    var fertilizerToWater = std.ArrayList(Range).init(allocator);
    defer fertilizerToWater.deinit();

    var waterToLight = std.ArrayList(Range).init(allocator);
    defer waterToLight.deinit();

    var lightToTemperature = std.ArrayList(Range).init(allocator);
    defer lightToTemperature.deinit();

    var temperatureToHumidity = std.ArrayList(Range).init(allocator);
    defer temperatureToHumidity.deinit();

    var humidityToLocation = std.ArrayList(Range).init(allocator);
    defer humidityToLocation.deinit();

    var lineNumber: u16 = 0;

    var readingValues = false;

    var map = std.ArrayList(u8).init(allocator);
    defer map.deinit();

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
            if (readingValues) {
                readingValues = false;
                map.clearRetainingCapacity();
            }
            continue;
        }

        if (lineNumber == 0) {
            var linePortions = std.mem.splitAny(u8, buffer.items, ":");
            _ = linePortions.next();
            var seedValues = std.mem.split(u8, linePortions.next().?, " ");
            while (seedValues.next()) |value| {
                if (value.len == 0) {
                    continue;
                }
                while (seedValues.next()) |pair| {
                    if (pair.len == 0) {
                        continue;
                    }
                    const start = std.fmt.parseInt(u64, value, 10) catch |err| {
                        print("Error parsing integer: {any}\n", .{err});
                        return;
                    };
                    const range = std.fmt.parseInt(u64, pair, 10) catch |err| {
                        print("Error parsing integer: {any}\n", .{err});
                        return;
                    };
                    seeds.append(SeedRange{ .start = start, .range = range }) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                    break;
                }
            }
        } else {
            if (!readingValues) {
                readingValues = true;
                var linePortions = std.mem.splitAny(u8, buffer.items, " ");
                const mapToRead = linePortions.next().?;
                map.appendSlice(mapToRead) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
            } else {
                var linePortions = std.mem.splitAny(u8, buffer.items, " ");
                const destination = std.fmt.parseInt(u64, linePortions.next().?, 10) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
                const source = std.fmt.parseInt(u64, linePortions.next().?, 10) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
                const range = std.fmt.parseInt(u64, linePortions.next().?, 10) catch |err| {
                    print("{any}\n", .{err});
                    return;
                };
                if (std.mem.eql(u8, map.items, "seed-to-soil")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    seedToSoil.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "soil-to-fertilizer")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    soilToFertilizer.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "fertilizer-to-water")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    fertilizerToWater.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "water-to-light")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    waterToLight.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "light-to-temperature")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    lightToTemperature.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "temperature-to-humidity")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    temperatureToHumidity.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else if (std.mem.eql(u8, map.items, "humidity-to-location")) {
                    const value = Range{ .source = source, .destination = destination, .range = range };
                    humidityToLocation.append(value) catch |err| {
                        print("{any}\n", .{err});
                        return;
                    };
                } else {
                    print("Unknown map: {s}\n", .{map.items});
                    return;
                }
            }
        }

        if (done) {
            break;
        }
        lineNumber += 1;
        buffer.clearRetainingCapacity();
    }
    var lowestLocation: ?u64 = null;

    // print("{any}\n", .{lightToTemperature});

    for (seeds.items) |seedRange| {
        for (seedRange.start..seedRange.start + seedRange.range) |seed| {
            var soil: ?u64 = null;
            for (seedToSoil.items) |rangeMap| {
                const dest = rangeMap.inSource(seed);
                if (dest != null) {
                    soil = dest;
                    break;
                }
            }
            if (soil == null) {
                soil = seed;
            }
            // print("Soil: {d}\n", .{soil.?});

            var fertilizer: ?u64 = null;
            for (soilToFertilizer.items) |rangeMap| {
                const dest = rangeMap.inSource(soil.?);
                if (dest != null) {
                    fertilizer = dest;
                    break;
                }
            }
            if (fertilizer == null) {
                fertilizer = soil;
            }
            // print("Fertilizer: {d}\n", .{fertilizer.?});

            var water: ?u64 = null;
            for (fertilizerToWater.items) |rangeMap| {
                const dest = rangeMap.inSource(fertilizer.?);
                if (dest != null) {
                    water = dest;
                    break;
                }
            }
            if (water == null) {
                water = fertilizer;
            }
            // print("Water: {d}\n", .{water.?});

            var light: ?u64 = null;
            for (waterToLight.items) |rangeMap| {
                const dest = rangeMap.inSource(water.?);
                if (dest != null) {
                    light = dest;
                    break;
                }
            }
            if (light == null) {
                light = water;
            }
            // print("Light: {d}\n", .{light.?});

            var temperature: ?u64 = null;
            // printNoArgs("Temperature to humidity\n");
            for (lightToTemperature.items) |rangeMap| {
                const dest = rangeMap.inSource(light.?);
                if (dest != null) {
                    temperature = dest;
                    break;
                }
            }
            if (temperature == null) {
                temperature = light;
            }
            // print("Temperature: {d}\n", .{temperature.?});

            var humidity: ?u64 = null;
            for (temperatureToHumidity.items) |rangeMap| {
                const dest = rangeMap.inSource(temperature.?);
                if (dest != null) {
                    humidity = dest;
                    break;
                }
            }
            if (humidity == null) {
                humidity = temperature;
            }
            // print("Humidity: {d}\n", .{humidity.?});

            var location: ?u64 = null;
            for (humidityToLocation.items) |rangeMap| {
                const dest = rangeMap.inSource(humidity.?);
                if (dest != null) {
                    location = dest;
                    break;
                }
            }
            if (location == null) {
                location = humidity;
            }
            // print("Location: {d}\n", .{location.?});

            if (lowestLocation == null or location.? < lowestLocation.?) {
                lowestLocation = location;
            }
        }
    }
    print("Part Two: {d}\n", .{lowestLocation.?});
}
