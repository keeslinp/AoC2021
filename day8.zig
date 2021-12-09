const std = @import("std");
const RAW_INPUT = @embedFile("./day8.txt");

fn countOnBits(num: u8) u8 {
    var temp = num;
    var count: u8 = 0;
    while (temp > 0) : (temp >>= 1) {
        if (temp & 1 == 1) count += 1;
    }
    return count;
}

test "countOnBits" {
    try std.testing.expectEqual(countOnBits(1), 1);
    try std.testing.expectEqual(countOnBits(2), 1);
    try std.testing.expectEqual(countOnBits(3), 2);
    try std.testing.expectEqual(countOnBits(4), 1);
    try std.testing.expectEqual(countOnBits(5), 2);
    try std.testing.expectEqual(countOnBits(6), 2);
    try std.testing.expectEqual(countOnBits(7), 3);
}

fn findIndex(list: []u8, num: u8) ?usize {
    for (list) |check, index| {
        if (check == num) return index;
    }
    return null;
}

fn posOfOne(num: u8) u8 {
    var pos: u8 = 0;
    var temp = nu;
    while (temp > 0) : (temp >>= 1) {
        if (temp & 1 > 0) return pos;
        pos += 1;
    }
    return pos;
}

fn contains(list: [10]u8, num: u8) bool {
    for (list) |check| {
        if (num == check) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    var count: u16 = 0;
    var lineIter = std.mem.tokenize(RAW_INPUT, "\n");
    var solutionSum: u32 = 0;
    while (lineIter.next()) |line| {
        var numbersDef = std.mem.zeroes([10]u8);
        var sectionIter = std.mem.tokenize(line, "|");
        const firstSection = sectionIter.next() orelse return error.BadFormat;
        const secondSection = sectionIter.next() orelse return error.BadFormat;
        var secondSectionIter = std.mem.tokenize(secondSection, " ");
        while (secondSectionIter.next()) |num| {
            switch (num.len) {
                2, 3, 4, 7 => {
                    count += 1;
                },
                else => {},
            }
        }
        const digitInputs = block: {
            var temp = std.mem.zeroes([10]u8);
            var firstSectionIter = std.mem.tokenize(firstSection, " ");
            var index: u8 = 0;
            while (firstSectionIter.next()) |num| {
                for (num) |c| {
                    temp[index] |= @intCast(u8, 1) << @intCast(u3, c - 'a');
                }
                index += 1;
            }
            break :block temp;
        };
        for (digitInputs) |digit| {
            switch (countOnBits(digit)) {
                2 => {
                    numbersDef[1] = digit;
                },
                3 => {
                    numbersDef[7] = digit;
                },
                4 => {
                    numbersDef[4] = digit;
                },
                7 => {
                    numbersDef[8] = digit;
                },
                else => {},
            }
        }
        numbersDef[9] = block: {
            for (digitInputs) |digit| {
                if (digit & numbersDef[4] == numbersDef[4] and !contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        numbersDef[3] = block: {
            for (digitInputs) |digit| {
                if (digit & numbersDef[1] == numbersDef[1] and countOnBits(digit) == 5 and !contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        numbersDef[0] = block: {
            for (digitInputs) |digit| {
                if (digit & numbersDef[1] == numbersDef[1] and countOnBits(digit) == 6 and !contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        numbersDef[6] = block: {
            for (digitInputs) |digit| {
                if (countOnBits(digit) == 6 and !contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        numbersDef[5] = block: {
            for (digitInputs) |digit| {
                if (digit & numbersDef[6] == digit and !contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        numbersDef[2] = block: {
            for (digitInputs) |digit| {
                if (!contains(numbersDef, digit)) break :block digit;
            }
            unreachable;
        };
        const rowSolution = block: {
            var total: u16 = 0;
            var iter = std.mem.tokenize(secondSection, " ");
            while (iter.next()) |num| {
                var acc: u8 = 0;
                for (num) |c| {
                    acc |= @intCast(u8, 1) << @intCast(u3, c - 'a');
                }
                total = total * 10 + @intCast(u8, findIndex(&numbersDef, acc) orelse return error.MissingNumber);
            }
            break :block total;
        };
        solutionSum += rowSolution;
    }
    std.debug.print("count: {}\n", .{count});
    std.debug.print("sums: {}\n", .{solutionSum});
}
