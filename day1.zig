const std = @import("std");

const Reader = std.fs.File.Reader;

const NumberIter = struct {
    buffer: [100]u8 = undefined,
    remaining: []const u8 = "",
    reader: Reader,
    pub fn next(self: *NumberIter) !?u16 {
        var acc: u16 = 0;
        while (true) {
            if (self.remaining.len == 0) {
                const readAmount = try self.reader.read(&self.buffer);
                if (readAmount == 0) {
                    return null;
                }
                self.remaining = self.buffer[0..readAmount];
            }
            for (self.remaining) |char, count| {
                if (char == '\n') {
                    self.remaining = self.remaining[(count + 1)..];
                    return acc;
                } else {
                    acc = (acc * 10) + (char - '0');
                }
            }
            self.remaining = "";
        }
        return acc;
    }

    pub fn new(reader: Reader) NumberIter {
        return NumberIter{
            .reader = reader,
        };
    }
};

fn part1() !u16 {
    const file = try std.fs.cwd().openFile(
        "day1.txt",
        .{ .read = true },
    );
    defer file.close();
    var iter = NumberIter.new(file.reader());
    var prev: u16 = (try iter.next()) orelse return 0;
    var count: u16 = 0;
    while (try iter.next()) |value| {
        if (value > prev) {
            count += 1;
        }
        prev = value;
    }
    return count;
}

fn RingBuffer(size: usize) type {
    return struct {
        values: [size]u16 = undefined,
        count: usize = 0,
        pub fn insert(self: *@This(), val: u16) void {
            self.values[self.count % size] = val;
            self.count += 1;
        }
        pub fn canSum(self: *@This()) bool {
            return self.count >= size;
        }
        pub fn sum(self: *@This()) u16 {
            var acc: u16 = 0;
            for (self.values) |val| {
                acc += val;
            }
            return acc;
        }
    };
}

fn part2() !u16 {
    const file = try std.fs.cwd().openFile(
        "day1.txt",
        .{ .read = true },
    );
    defer file.close();
    var iter = NumberIter.new(file.reader());
    var prevSum: ?u16 = null;
    var count: u16 = 0;
    var ringBuffer = RingBuffer(3){};
    while (try iter.next()) |value| {
        ringBuffer.insert(value);
        if (ringBuffer.canSum()) {
            const newSum = ringBuffer.sum();
            if (prevSum) |p| {
                if (newSum > p) {
                    count += 1;
                }
            }
            prevSum = newSum;
        }
    }
    return count;
}

pub fn main() !void {
    std.debug.print("part1: {}\n", .{part1()});
    std.debug.print("part2: {}\n", .{part2()});
}
