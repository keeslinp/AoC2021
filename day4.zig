const RAW_INPUT = @embedFile("./day4.txt");
const RAW_BOARD_SIZE: usize = 3 * 5 * 5;
const std = @import("std");

const Cell = struct {
    num: u8,
    filled: bool = false,
};

const WINNERS = [10][5]usize{
    .{ 0, 1, 2, 3, 4 },
    .{ 5, 6, 7, 8, 9 },
    .{ 10, 11, 12, 13, 14 },
    .{ 15, 16, 17, 18, 19 },
    .{ 20, 21, 22, 23, 24 },
    .{ 0, 5, 10, 15, 20 },
    .{ 1, 6, 11, 16, 21 },
    .{ 2, 7, 12, 17, 22 },
    .{ 3, 8, 13, 18, 23 },
    .{ 4, 9, 14, 19, 24 },
};

const Board = struct {
    cells: [5 * 5]Cell,
    pub fn init(input: []const u8) Board {
        var cells: [5 * 5]Cell = undefined;
        var cellIndex: usize = 0;
        var insideNum: bool = false;
        var pendingNum: u8 = 0;
        for (input) |char| {
            switch (char) {
                ' ', '\n' => {
                    if (insideNum) {
                        cells[cellIndex] = Cell{
                            .num = pendingNum,
                        };
                        cellIndex += 1;
                    }
                    pendingNum = 0;
                    insideNum = false;
                },
                else => {
                    insideNum = true;
                    pendingNum = pendingNum * 10 + (char - '0');
                },
            }
        }
        std.debug.assert(cellIndex == 25);
        return Board{
            .cells = cells,
        };
    }

    pub fn clean(self: *Board) void {
        for (self.cells) |*cell| {
            cell.filled = false;
        }
    }

    pub fn mark(self: *Board, play: u8) void {
        for (self.cells) |*cell| {
            if (cell.num == play) {
                cell.filled = true;
            }
        }
    }

    pub fn winner(self: *const Board) bool {
        for (WINNERS) |required| {
            var all = true;
            for (required) |cellIndex| {
                if (!self.cells[cellIndex].filled) {
                    all = false;
                    break;
                }
            }
            if (all) {
                return true;
            }
        }
        return false;
    }
    pub fn unmarkedSum(self: *const Board) u32 {
        var sum: u32 = 0;
        for (self.cells) |cell| {
            if (!cell.filled) {
                sum += cell.num;
            }
        }
        return sum;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();
    var takenBytes: usize = 0;
    const plays = block: {
        var list = std.ArrayList(u8).init(&arena.allocator);
        var pending: u8 = 0;
        for (RAW_INPUT) |char, index| {
            takenBytes += 1;
            switch (char) {
                '\n' => break,
                ',' => {
                    try list.append(pending);
                    pending = 0;
                },
                else => pending = pending * 10 + (char - '0'),
            }
        }
        break :block list;
    };
    var boards = block: {
        var list = std.ArrayList(Board).init(&arena.allocator);
        while (takenBytes < RAW_INPUT.len) {
            takenBytes += 1;
            try list.append(Board.init(RAW_INPUT[takenBytes .. takenBytes + RAW_BOARD_SIZE]));
            takenBytes += RAW_BOARD_SIZE;
        }
        break :block list;
    };
    const part1: u32 = block: {
        for (plays.items) |play| {
            for (boards.items) |*board| {
                board.mark(play);
                if (board.winner()) {
                    break :block board.unmarkedSum() * play;
                }
            }
        }
        unreachable;
    };

    for (boards.items) |*board| {
        board.clean();
    }

    const part2: u32 = block: {
        var remaining: usize = boards.items.len;
        for (plays.items) |play| {
            for (boards.items) |*board| {
                if (board.winner()) { // Not perfomant but who gives
                    continue;
                }
                board.mark(play);
                if (board.winner()) {
                    remaining -= 1;
                    if (remaining == 0) {
                        break :block board.unmarkedSum() * play;
                    }
                }
            }
        }
        unreachable;
    };

    std.debug.print("part1: {}\n", .{part1});
    std.debug.print("part2: {}\n", .{part2});
}
