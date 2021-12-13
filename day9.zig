const RAW_INPUT = @embedFile("./day9.txt");
const std = @import("std");

const ROW_SIZE: usize = 10; // Not including endline
const totalLines = comptime std.mem.count(u8, RAW_INPUT, "\n");

fn h(x: usize, y: usize) u8 {
    return RAW_INPUT[y * (ROW_SIZE + 1) + x] - '0';
}

fn part1() u16 {
    var sum: u16 = 0;
    var y: usize = 0;
    while (y < totalLines) : (y += 1) {
        var x: usize = 0;
        while (x < ROW_SIZE) : (x += 1) {
            const currentHeight = h(x, y);
            if (x > 0 and h(x - 1, y) <= currentHeight) continue;
            if ((x + 1) < ROW_SIZE and h(x + 1, y) <= currentHeight) continue;
            if ((y + 1) < totalLines and h(x, y + 1) <= currentHeight) continue;
            if (y > 0 and h(x, y - 1) <= currentHeight) continue;
            sum += currentHeight + 1;
        }
    }
    return sum;
}

fn sizeOfBasinAt(x: usize, y: usize) u16 {
    var size: u16 = 1;
    const currentHeight = h(x, y);
    if (currentHeight == 9) return 0;
    if (x > 0 and h(x - 1, y) > currentHeight) size += sizeOfBasinAt(x - 1, y);
    if ((x + 1) < ROW_SIZE and h(x + 1, y) > currentHeight) size += sizeOfBasinAt(x + 1, y);
    if ((y + 1) < totalLines and h(x, y + 1) > currentHeight) size += sizeOfBasinAt(x, y + 1);
    if (y > 0 and h(x, y - 1) > currentHeight) size += sizeOfBasinAt(x, y - 1);
    return size;
}

fn part2() u16 {
    var top3 = std.mem.zeroes([3]u16);
    var y: usize = 0;
    while (y < totalLines) : (y += 1) {
        var x: usize = 0;
        while (x < ROW_SIZE) : (x += 1) {
            std.debug.print("top3: {d}\n", .{top3});
            const size = sizeOfBasinAt(x, y);
            if (size > top3[0]) {
                top3[0] = size;
                std.sort.sort(u16, &top3, {}, comptime std.sort.asc(u16));
            }
        }
    }
    var product: u16 = 1;
    for (top3) |size| {
        product *= size;
    }
    return product;
}

pub fn main() !void {
    std.debug.print("part1: {}\n", .{part1()});
    std.debug.print("part2: {}\n", .{part2()});
}
