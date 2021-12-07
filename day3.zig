const std = @import("std");
const Reader = std.fs.File.Reader;

const rowType: type = u12;
const ROW_SIZE = @bitSizeOf(rowType);

const RowIter = struct {
    buffer: [(ROW_SIZE + 1) * 10]u8 = undefined,
    remaining: []const u8 = "",
    reader: Reader,
    pub fn next(self: *RowIter) !?[]const u8 {
        if (self.remaining.len <= ROW_SIZE) {
            const readCount = try self.reader.readAll(&self.buffer);
            if (readCount == 0) {
                return null;
            }
            self.remaining = self.buffer[0..readCount];
        }
        const result = self.remaining[0..ROW_SIZE];
        self.remaining = self.remaining[ROW_SIZE + 1 ..];
        return result;
    }
    pub fn new(reader: Reader) RowIter {
        return RowIter{
            .reader = reader,
        };
    }
};

fn getGamma(reader: Reader) !rowType {
    var iter = RowIter.new(reader);
    var acc: [ROW_SIZE]u16 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var totalCount: u16 = 0;
    while (try iter.next()) |row| {
        for (row) |cell, index| {
            acc[index] += cell - '0';
        }
        totalCount += 1;
    }
    var result: rowType = 0;
    for (acc) |cellSum| {
        result <<= 1;
        if (cellSum > totalCount / 2) {
            result += 1;
        }
    }
    return result;
}

fn part1() !u32 {
    const file = try std.fs.cwd().openFile(
        "day3.txt",
        .{ .read = true },
    );
    const gamma = try getGamma(file.reader());
    return @intCast(u32, gamma) * @intCast(u32, ~gamma);
}

fn packBits(bits: []const u8) rowType {
    var acc: u12 = 0;
    for (bits) |b| {
        acc <<= 1;
        acc += b - '0';
    }
    return @intCast(rowType, acc);
}

fn calculate(alloc: *std.mem.Allocator, oxygen: bool, initialRows: *const std.ArrayList(rowType)) !rowType {
    var rowList = initialRows.*;
    var filterIndex: u4 = @bitSizeOf(rowType) - 1;
    while (rowList.items.len > 1) {
        const mask: rowType = @intCast(rowType, 1) << filterIndex;
        const flagBit: rowType = block: {
            var acc: i16 = 0;
            for (rowList.items) |row| {
                if (mask & row > 0) {
                    acc += 1;
                } else {
                    acc -= 1;
                }
            }
            if (oxygen) {
                if (acc >= 0) {
                    break :block 1;
                } else {
                    break :block 0;
                }
            } else {
                if (acc < 0) {
                    break :block 1;
                } else {
                    break :block 0;
                }
            }
        };
        var newList = std.ArrayList(rowType).init(alloc);
        for (rowList.items) |row| {
            if (row & mask == flagBit << filterIndex) {
                try newList.append(row);
            }
        }
        rowList = newList;
        if (filterIndex == 0) {
            break;
        }
        filterIndex -= 1;
    }

    return rowList.items[0];
}

fn part2() !u32 {
    const file = try std.fs.cwd().openFile(
        "day3.txt",
        .{ .read = true },
    );
    var sigBit: u4 = ROW_SIZE - 1;
    var oxyMask: rowType = 0;
    var co2Mask: rowType = 0;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();
    var rowList = std.ArrayList(rowType).init(&arena.allocator);
    var rowIter = RowIter.new(file.reader());
    while (try rowIter.next()) |next| {
        try rowList.append(packBits(next));
    }
    const oxygenValue = try calculate(&arena.allocator, true, &rowList);
    const co2Value = try calculate(&arena.allocator, false, &rowList);
    return @intCast(u32, oxygenValue) * @intCast(u32, co2Value);
}

pub fn main() !void {
    std.debug.print("part1: {}\n", .{part1()});
    std.debug.print("part2: {}\n", .{part2()});
}
