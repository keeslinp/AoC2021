const std = @import("std");
const RAW_INPUT = @embedFile("./day6.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var fishCounts = [9]u64{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var initialStateIter = std.mem.tokenize(RAW_INPUT[0 .. RAW_INPUT.len - 1], ",");
    while (initialStateIter.next()) |num| {
        fishCounts[try std.fmt.parseInt(usize, num, 10)] += 1;
    }
    var day: u16 = 0;
    while (day < 256) : (day += 1) {
        const newFishes = [9]u64{ fishCounts[1], fishCounts[2], fishCounts[3], fishCounts[4], fishCounts[5], fishCounts[6], fishCounts[7] + fishCounts[0], fishCounts[8], fishCounts[0] };
        fishCounts = newFishes;
    }
    var acc: u64 = 0;
    for (fishCounts) |count| {
        acc += count;
    }
    std.debug.print("fish count: {}\n", .{acc});
}
