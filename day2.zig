const std = @import("std");

const Reader = std.fs.File.Reader;

const Direction = enum {
    Up,
    Down,
    Forward,
};

const Move = struct {
    dir: Direction,
    dist: u16,
};

const MoveIter = struct {
    buffer: [100]u8 = undefined,
    remaining: []const u8 = "",
    reader: Reader,
    fn nextBlock(self: *MoveIter) !usize {
        const readAmount = try self.reader.read(&self.buffer);
        self.remaining = self.buffer[0..readAmount];
        return readAmount;
    }

    fn skip(self: *MoveIter, skipAmount: usize) !void {
        var remainingSkip = skipAmount;
        while (remainingSkip > 0 and self.remaining.len > 0) {
            if (self.remaining.len > remainingSkip) {
                self.remaining = self.remaining[remainingSkip..];
                remainingSkip = 0;
            } else {
                remainingSkip -= self.remaining.len;
                _ = try self.nextBlock();
            }
        }
    }

    fn readDirection(self: *MoveIter) !?Direction {
        if (self.remaining.len == 0) {
            if ((try self.nextBlock()) == 0) {
                return null;
            }
        }
        return switch (self.remaining[0]) {
            'f' => Direction.Forward,
            'd' => Direction.Down,
            'u' => Direction.Up,
            else => null,
        };
    }

    pub fn next(self: *MoveIter) !?Move {
        const dir = (try self.readDirection()) orelse return null;
        try self.skip(@tagName(dir).len + 1);
        if (self.remaining.len == 0) {
            if ((try self.nextBlock()) == 0) {
                return null;
            }
        }
        const distance = self.remaining[0] - '0';
        try self.skip(2); // skip number and newline
        return Move{
            .dir = dir,
            .dist = distance,
        };
    }

    pub fn new(reader: Reader) MoveIter {
        return MoveIter{
            .reader = reader,
        };
    }
};

fn part1() !u32 {
    const file = try std.fs.cwd().openFile(
        "day2.txt",
        .{ .read = true },
    );
    defer file.close();
    var iter = MoveIter.new(file.reader());
    var verticalSum: u32 = 0;
    var horizontalSum: u32 = 0;
    while (try iter.next()) |move| {
        switch (move.dir) {
            Direction.Forward => horizontalSum += move.dist,
            Direction.Up => verticalSum -= move.dist,
            Direction.Down => verticalSum += move.dist,
        }
    }
    return verticalSum * horizontalSum;
}

fn part2() !u32 {
    const file = try std.fs.cwd().openFile(
        "day2.txt",
        .{ .read = true },
    );
    defer file.close();
    var iter = MoveIter.new(file.reader());
    var verticalSum: u32 = 0;
    var horizontalSum: u32 = 0;
    var aim: u16 = 0;
    while (try iter.next()) |move| {
        switch (move.dir) {
            Direction.Forward => {
                horizontalSum += move.dist;
                verticalSum += move.dist * aim;
            },
            Direction.Up => aim -= move.dist,
            Direction.Down => aim += move.dist,
        }
    }
    return verticalSum * horizontalSum;
}

pub fn main() !void {
    std.debug.print("part1: {}\n", .{part1()});
    std.debug.print("part2: {}\n", .{part2()});
}
