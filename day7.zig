const std = @import("std");
const RAW_INPUT = @embedFile("./day7.txt");

pub fn main() !void {
    var gca = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(&gca.allocator);
    var numIter = std.mem.tokenize(RAW_INPUT[0 .. RAW_INPUT.len - 1], ",");
    var buffer = std.ArrayList(u16).init(&arena.allocator); // Heap would be faster :shrug:
    while (numIter.next()) |num| {
        try buffer.append(try std.fmt.parseInt(u16, num, 10));
    }
    std.sort.sort(u16, buffer.items, {}, comptime std.sort.asc(u16));
    const median: u16 = if (buffer.items.len % 2 == 0) buffer.items[buffer.items.len / 2] else ((buffer.items[buffer.items.len / 2] + buffer.items[buffer.items.len / 2 + 1]) / 2);
    var acc: u32 = 0;
    for (buffer.items) |pos| {
        if (median > pos) {
            acc += median - pos;
        } else {
            acc += pos - median;
        }
    }

    std.debug.print("median: {}, total fuel: {}\n", .{ median, acc });
    var sum: u32 = 0;
    for (buffer.items) |pos| {
        sum += pos;
    }

    var testLocation = buffer.items[0];
    const max = buffer.items[buffer.items.len - 1];
    var minFuel: u32 = std.math.maxInt(u32);
    while (testLocation < max) : (testLocation += 1) {
        var fuelSum: u32 = 0;
        for (buffer.items) |pos| {
            const dist: f32 = @intToFloat(f32, if (testLocation > pos) testLocation - pos else pos - testLocation);
            fuelSum += @floatToInt(u32, (dist + 1) * (dist / 2));
        }
        minFuel = std.math.min(minFuel, fuelSum);
    }

    std.debug.print("minFuel: {}\n", .{minFuel});
}
