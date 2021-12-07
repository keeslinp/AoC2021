const std = @import("std");
const RAW_INPUT = @embedFile("./day5.txt");

const Coord = struct {
    x: u16,
    y: u16,

    pub fn parse(input: []const u8) !Coord {
        var pieceIter = std.mem.tokenize(input, ",");
        const x = try std.fmt.parseInt(u16, pieceIter.next() orelse return error.BadCoord, 10);
        const y = try std.fmt.parseInt(u16, pieceIter.next() orelse return error.BadCoord, 10);
        return Coord{
            .x = x,
            .y = y,
        };
    }
};

const CoordIter = struct {
    start: Coord,
    curr: Coord,
    end: Coord,
    done: bool = false, // This seems dumb but easy

    pub fn next(self: *CoordIter) ?Coord {
        const curr = self.curr; // save so that our changes don't affect it
        if (self.curr.x < self.end.x) {
            self.curr.x += 1;
        }
        if (self.curr.y < self.end.y) {
            self.curr.y += 1;
        }

        if (self.curr.x > self.end.x) {
            self.curr.x -= 1;
        }

        if (self.curr.y > self.end.y) {
            self.curr.y -= 1;
        }

        if (self.done) {
            return null;
        }
        if (curr.x == self.end.x and curr.y == self.end.y) {
            self.done = true;
        }
        return curr;
    }

    pub fn new(start: Coord, end: Coord) CoordIter {
        return CoordIter{
            .start = start,
            .end = end,
            .curr = start,
        };
    }
};

const Line = struct {
    start: Coord,
    end: Coord,

    pub fn parse(input: []const u8) !Line {
        var chunkIter = std.mem.tokenize(input, " ");
        const start = try Coord.parse(chunkIter.next() orelse return error.BadLine);
        _ = chunkIter.next() orelse return error.BadLine;
        const end = try Coord.parse(chunkIter.next() orelse return error.BadLine);
        return Line{
            .start = start,
            .end = end,
        };
    }

    pub fn coordIter(self: *const Line) CoordIter {
        return CoordIter.new(self.start, self.end);
    }

    pub fn isHorizontal(self: *const Line) bool {
        return self.start.x == self.end.x or self.start.y == self.end.y;
    }
};

const LineIter = struct {
    rawLineIter: std.mem.TokenIterator = std.mem.tokenize(RAW_INPUT, "\n"),
    pub fn next(self: *LineIter) !?Line {
        if (self.rawLineIter.next()) |command| {
            return try Line.parse(command);
        } else {
            return null;
        }
    }
};

const ROW_SIZE: usize = 1000;

fn countOverlap(includeDiagonal: bool) !u16 {
    var cells: [ROW_SIZE * ROW_SIZE]u8 = undefined;
    for (cells) |*cell| {
        cell.* = 0;
    }
    var lineIter = LineIter{};
    while (try lineIter.next()) |line| {
        if (includeDiagonal or line.isHorizontal()) {
            var coords = line.coordIter();
            while (coords.next()) |coord| {
                cells[coord.y * ROW_SIZE + coord.x] += 1;
            }
        }
    }

    var acc: u16 = 0;
    for (cells) |cell| {
        if (cell > 1) {
            acc += 1;
        }
    }
    return acc;
}

pub fn main() !void {
    std.debug.print("part1: {}\n", .{try countOverlap(false)});
    std.debug.print("part2: {}\n", .{try countOverlap(true)});
}
