const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day11(allocator: Allocator, reader: *Reader) ![3]u64 {
    var columns = try readColumns(allocator, reader);
    _ = normalizeFlock(&columns, 10);
    const result1 = checksum(&columns);

    columns = try readColumns(allocator, reader);
    const result2 = normalizeFlock(&columns, 100000000000);

    columns = try readColumns(allocator, reader);
    const result3 = countMovesToNormalizeSorted(&columns);

    return [3]u64{result1, result2, result3};
}

pub fn day12(allocator: Allocator, reader: *Reader) ![3]u64 {
    var grid: [210][210]u8 = @splat(@splat(0));
    var y1: usize = 0;
    var xDim: usize = 0;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        xDim = line.len;
        for(line, 0..) |char, x1| {
            grid[x1][y1] = char - '0';
        }
        y1 += 1;
    }
    var yDim = y1;

    var burned = std.AutoHashMap(UCoord, void).init(allocator);
    var queue = std.Deque(UCoord).empty;
    try queue.pushFront(allocator, .{.x = 0, .y = 0});
    try burned.put(.{.x = 0, .y = 0}, void{});
    const result1 = try igniteBarrels(&grid, &queue, &burned, xDim, yDim, allocator);

    y1 = 0;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        xDim = line.len;
        for(line, 0..) |char, x1| {
            grid[x1][y1] = char - '0';
        }
        y1 += 1;
    }
    yDim = y1;

    burned.clearRetainingCapacity();
    try queue.pushFront(allocator, .{.x = 0, .y = 0});
    try queue.pushFront(allocator, .{.x = xDim - 1, .y = yDim - 1});
    try burned.put(.{.x = 0, .y = 0}, void{});
    try burned.put(.{.x = xDim - 1, .y = yDim - 1}, void{});
    const result2 = try igniteBarrels(&grid, &queue, &burned, xDim, yDim, allocator);

    y1 = 0;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        xDim = line.len;
        for(line, 0..) |char, x1| {
            grid[x1][y1] = char - '0';
        }
        y1 += 1;
    }
    yDim = y1;


    burned.clearRetainingCapacity();
    const result3 = try find3Best(&grid, xDim, yDim, allocator);

    return [3]u64{result1, result2, result3};
}

fn find3Best(grid: *[210][210]u8, xDim: usize, yDim: usize, allocator: Allocator) !u32 {
    var result = std.AutoHashMap(UCoord, void).init(allocator);
    var currentCheckedBarrels = std.AutoHashMap(UCoord, void).init(allocator);
    var queue = std.Deque(UCoord).empty;

    for(0..3) |_| {
        var maxBurned: u32 = 0;
        var maxCoord: UCoord = UCoord{.x = 0, .y = 0};
        for(0..xDim) |x| {
            for(0..yDim) |y| {
                const coord = UCoord{.x = x, .y = y};
                if(grid[coord.x][coord.y] > 3 and !currentCheckedBarrels.contains(coord)) {
                    try queue.pushFront(allocator, coord);
                    var tempStorage = try result.clone();
                    try tempStorage.put(coord, void{});
                    const burned = try igniteBarrels(grid, &queue, &tempStorage, xDim, yDim, allocator);
                    if(burned > maxBurned) {
                        maxBurned = burned;
                        maxCoord = coord;
                    }
                    try putAll(&tempStorage, &currentCheckedBarrels);
                }
            }
        }
        // Add all burned barrels to result set
        try queue.pushFront(allocator, maxCoord);
        try result.put(maxCoord, void{});
        const total = try igniteBarrels(grid, &queue, &result, xDim, yDim, allocator);
        std.debug.print("{d} {} {d}\n", .{total, maxCoord, grid[maxCoord.x][maxCoord.y]});

        // Never check barrels in the result set again
        currentCheckedBarrels.clearRetainingCapacity();
        try putAll(&result, &currentCheckedBarrels);

        // Reset max
        maxCoord = UCoord{.x = 0, .y = 0};
        maxBurned = 0;
    }

    return result.count();
}

fn putAll(source: *std.AutoHashMap(UCoord, void), target: *std.AutoHashMap(UCoord, void)) !void {
    var it = source.keyIterator();
    while(it.next()) |key| {
        try target.put(key.*, void{});
    }
}

fn igniteBarrels(grid: *[210][210]u8, queue: *std.Deque(UCoord), burned: *std.AutoHashMap(UCoord, void), xDim: usize, yDim: usize, allocator: Allocator) !u32 {
    while(queue.popBack()) |coord| {
        if(coord.y > 0 and grid[coord.x][coord.y-1] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x, .y = coord.y - 1};
            if(!burned.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.y < yDim - 1 and grid[coord.x][coord.y+1] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x, .y = coord.y + 1};
            if(!burned.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.x > 0 and grid[coord.x-1][coord.y] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x - 1, .y = coord.y};
            if(!burned.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.x < xDim - 1 and grid[coord.x+1][coord.y] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x + 1, .y = coord.y};
            if(!burned.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
    }
    return burned.count();
}

fn countMovesToNormalizeSorted(columns: *std.ArrayList(u64)) u64 {
    var average: u64 = 0;
    for(columns.items) |item| {
        average += item;
    }
    average /= columns.items.len;

    var result: u64 = 0;
    for(columns.items) |item| {
        if(item > average) {
            result += item - average;
        }
    }
    return result;
}

fn readColumns(allocator: Allocator, reader: *Reader) !std.ArrayList(u64) {
    var result = std.ArrayList(u64).empty;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        try result.append(allocator, try std.fmt.parseInt(u64, line, 10));
    }
    return result;
}

fn normalizeFlock(columns: *std.ArrayList(u64), maxRounds: usize) u32 {
    var moved = true;
    var rounds: usize = 0;
    while(moved and rounds < maxRounds) {
        moved = false;
        for(0..columns.items.len - 1) |i| {
            const cur = columns.items[i];
            const next = columns.items[i+1];
            if(next < cur) {
                columns.items[i] -= 1;
                columns.items[i+1] += 1;
                moved = true;
            }
        }
        if(moved) {
            rounds += 1;
        }
    }

    moved = true;
    while(moved and rounds < maxRounds) {
        moved = false;
        for(0..columns.items.len - 1) |i| {
            const cur = columns.items[i];
            const next = columns.items[i+1];
            if(next > cur) {
                columns.items[i] += 1;
                columns.items[i+1] -= 1;
                moved = true;
            }
        }
        if(moved) {
            rounds += 1;
        }
    }
    return @intCast(rounds);
}

fn checksum(columns: *std.ArrayList(u64)) u64 {
    var result: u64 = 0;
    for(columns.items, 1..) |column, i| {
        result += column * @as(u32, @intCast(i));
    }
    return result;
}

const UCoord = struct {
    x: usize,
    y: usize,
};
