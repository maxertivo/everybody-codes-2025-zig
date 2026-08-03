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
    const empty = std.AutoHashMap(UCoord, void).init(allocator);
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
    const result1 = try igniteBarrels(&grid, &queue, &burned, &empty, xDim, yDim, allocator);

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
    const result2 = try igniteBarrels(&grid, &queue, &burned, &empty, xDim, yDim, allocator);

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

pub fn day13(allocator: Allocator, reader: *Reader) ![3]u64 {
    var list1 = std.ArrayList(u32).empty;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        try list1.append(allocator, try std.fmt.parseInt(u32, line, 10));
    }

    var wheel: []u32 = try allocator.alloc(u32, list1.items.len + 1);
    @memset(wheel, 0);
    wheel[0] = 1;
    var reverseIndex: usize = list1.items.len;
    var forwardIndex: usize = 1;
    for(list1.items, 0..) |item, i| {
        if(i % 2 == 0) {
            wheel[forwardIndex] = item;
            forwardIndex += 1;
        } else {
            wheel[reverseIndex] = item;
            reverseIndex -= 1;
        }
    }
    const result1: u64 = wheel[2025 % wheel.len];

    var list2 = try parseList(allocator, reader);

    const result2 = try turnWheel(&list2, allocator, 20252025);

    var list3 = try parseList(allocator, reader);
    const result3 = try turnWheel(&list3, allocator, 202520252025);

    return [3]u64{result1,result2,result3};
}

pub fn day14(allocator: Allocator, reader: *Reader) ![3]u64 {
    var bitSet, const rowLen, const total = try parseTiles(allocator, reader);

    var storage = try std.bit_set.DynamicBitSet.initEmpty(allocator, total);
    var result1: u64 = 0;
    for(0..5) |_| {
        try performRound(std.bit_set.DynamicBitSet, &bitSet, &storage, rowLen);
        result1 += storage.count();
        try performRound(std.bit_set.DynamicBitSet, &storage, &bitSet, rowLen);
        result1 += bitSet.count();
    }

    var bitSet2, const rowLen2, const total2 = try parseTiles(allocator, reader);

    var storage2 = try std.bit_set.DynamicBitSet.initEmpty(allocator, total2);
    var result2: u64 = 0;
    for(0..1012) |_| {
        try performRound(std.bit_set.DynamicBitSet, &bitSet2, &storage2, rowLen2);
        result2 += storage2.count();
        try performRound(std.bit_set.DynamicBitSet, &storage2, &bitSet2, rowLen2);
        result2 += bitSet2.count();
    }
    try performRound(std.bit_set.DynamicBitSet, &bitSet2, &storage2, rowLen2);
    result2 += storage2.count();

    const pattern, _, _ = try parseTiles(allocator, reader);

    var bitSet3 = std.bit_set.IntegerBitSet(1156).empty;
    var storage3 = std.bit_set.IntegerBitSet(1156).empty;
    var seen = std.AutoHashMap(u1156, usize).init(allocator);
    var pointValuesByIndex = std.AutoHashMap(usize, u64).init(allocator);
    var cycleLength: usize = 0;
    var cycleEnd: usize = 0;
    var result3: u64 = 0;
    for(0..100000000) |i| {
        try performRound(std.bit_set.IntegerBitSet(1156), &bitSet3, &storage3, 34);
        if(containsPattern(&storage3, &pattern)) {
            const count = storage3.count();
            try pointValuesByIndex.put(2*i + 1, count);
        }

        if(seen.get(storage3.mask)) |seenIndex| {
            cycleEnd = 2*i + 1;
            cycleLength = cycleEnd - seenIndex;
            break;
        }
        try seen.put(storage3.mask, 2*i + 1);
        try performRound(std.bit_set.IntegerBitSet(1156), &storage3, &bitSet3, 34);
        if(containsPattern(&bitSet3, &pattern)) {
            const count = bitSet3.count();
            try pointValuesByIndex.put(2*i + 2, count);
        }
        if(seen.get(bitSet3.mask)) |seenIndex| {
            cycleEnd = 2*i + 2;
            cycleLength = cycleEnd - seenIndex;
            break;
        }
        try seen.put(bitSet3.mask, 2*i + 2);
    }
    const numCycles: usize = 1000000000;
    const cycleStart: usize = cycleEnd - cycleLength;
    const fullCycles: usize = (numCycles - cycleStart) / cycleLength;
    const remainingRounds: usize = @mod(numCycles - cycleStart, cycleLength);

    // Add points during cycle
    for(cycleStart..cycleStart + cycleLength) |i| {
        if(pointValuesByIndex.get(i)) |pointValue| {
            result3 += pointValue;
        }
    }
    result3 *= @intCast(fullCycles);

    // Add points before cycle
    for(0..cycleStart) |i| {
        if(pointValuesByIndex.get(i)) |pointValue| {
            result3 += pointValue;
        }
    }

    // Add partial cycle at the end
    for(cycleStart..cycleStart + remainingRounds) |i| {
        if(pointValuesByIndex.get(i)) |pointValue| {
            result3 += pointValue;
        }
    }

    return [3]u64{result1, result2, result3};
}

fn containsPattern(tiles: *const std.bit_set.IntegerBitSet(1156), pattern: *const std.bit_set.DynamicBitSet) bool {
    return tiles.isSet(455) == pattern.isSet(0)
        and tiles.isSet(456) == pattern.isSet(1)
        and tiles.isSet(457) == pattern.isSet(2)
        and tiles.isSet(458) == pattern.isSet(3)
        and tiles.isSet(489) == pattern.isSet(8)
        and tiles.isSet(490) == pattern.isSet(9)
        and tiles.isSet(491) == pattern.isSet(10)
        and tiles.isSet(492) == pattern.isSet(11)
        and tiles.isSet(523) == pattern.isSet(16)
        and tiles.isSet(524) == pattern.isSet(17)
        and tiles.isSet(525) == pattern.isSet(18)
        and tiles.isSet(526) == pattern.isSet(19)
        and tiles.isSet(557) == pattern.isSet(24)
        and tiles.isSet(558) == pattern.isSet(25)
        and tiles.isSet(559) == pattern.isSet(26)
        and tiles.isSet(560) == pattern.isSet(27);
}

fn parseTiles(allocator: Allocator, reader: *Reader) !struct{std.bit_set.DynamicBitSet, usize, usize} {
    var list = std.ArrayList([]u8).empty;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        try list.append(allocator, try allocator.dupe(u8, line));
    }
    const rowLen: usize = list.items[0].len;
    const total: usize = list.items.len * rowLen;
    var bitSet = try std.bit_set.DynamicBitSet.initEmpty(allocator, total);
    for(list.items, 0..) |item, i| {
        for(item, 0..) |char, j| {
            if(char == '#') {
                bitSet.set(rowLen * i + j);
            }
        }
    }
    return .{bitSet, rowLen, total};
}

fn performRound(comptime T: type, src: *T, dest: *T, rowLen: usize) !void {
    for(0..src.capacity()) |index| {
        var count: u8 = 0;
        if(index % rowLen > 0 and index >= rowLen + 1 and src.isSet(index - 1 - rowLen)) {
            count += 1;
        }
        if(index % rowLen < rowLen - 1 and index >= rowLen - 1 and src.isSet(index + 1 - rowLen)) {
            count += 1;
        }
        if(index % rowLen > 0 and index + rowLen - 1 < src.capacity() and src.isSet(index + rowLen - 1)) {
            count += 1;
        }
        if(index % rowLen < rowLen - 1 and index + rowLen + 1 < src.capacity() and src.isSet(index + rowLen + 1)) {
            count += 1;
        }
        //std.debug.print("index: {d} count: {d}\n",.{index, count});
        if(src.isSet(index)) {
            if(count % 2 == 1) {
                dest.set(index);
            } else {
                dest.unset(index);
            }
        } else {
            if(count % 2 == 1) {
                dest.unset(index);
            } else {
                dest.set(index);
            }
        }
    }
}

fn parseList(allocator: Allocator, reader: *Reader) !std.ArrayList(Range) {
    var list = std.ArrayList(Range).empty;
    var asc = true;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            break;
        }
        var it = std.mem.tokenizeScalar(u8, line, '-');
        const start = try std.fmt.parseInt(u32, it.next().?, 10);
        const end = try std.fmt.parseInt(u32, it.next().?, 10);
        if(asc) {
            try list.append(allocator, .{.start = start, .end = end, .asc = asc});
        } else {
            try list.append(allocator, .{.start = end, .end = start, .asc = asc});
        }
        asc = !asc;
    }
    return list;
}

fn turnWheel(list: *std.ArrayList(Range), allocator: Allocator, units: u64) !u64 {
    var wheel = try allocator.alloc(Range, list.items.len + 1);
    @memset(wheel, .{.start = 0, .end = 0, .asc = false});
    wheel[0] = .{.start = 1, .end = 1, .asc = true};
    var reverseIndex: usize = list.items.len;
    var forwardIndex: usize = 1;
    for(list.items, 0..) |item, i| {
        if(i % 2 == 0) {
            wheel[forwardIndex] = item;
            forwardIndex += 1;
        } else {
            wheel[reverseIndex] = item;
            reverseIndex -= 1;
        }
    }
    var totalLen: u64 = 0;
    for(wheel) |item| {
        totalLen += item.size();
    }
    var remainder:u64 = units % totalLen;
    for(wheel) |item| {
        if(item.size() <= remainder) {
            remainder -= item.size();
        } else if (item.asc) {
            return item.start + remainder;
        } else {
            return item.start - remainder;
        }
    }
    unreachable;
}

fn find3Best(grid: *[210][210]u8, xDim: usize, yDim: usize, allocator: Allocator) !u32 {
    var result = std.AutoHashMap(UCoord, void).init(allocator);
    var currentCheckedBarrels = std.AutoHashMap(UCoord, void).init(allocator);
    var tempStorage = std.AutoHashMap(UCoord, void).init(allocator);
    const empty = std.AutoHashMap(UCoord, void).init(allocator);
    var queue = std.Deque(UCoord).empty;

    for(0..3) |_| {
        var maxBurned: u32 = 0;
        var maxCoord: UCoord = UCoord{.x = 0, .y = 0};
        for(0..xDim) |x| {
            for(0..yDim) |y| {
                const coord = UCoord{.x = x, .y = y};
                if(grid[coord.x][coord.y] > 3 and !currentCheckedBarrels.contains(coord)) {
                    try queue.pushFront(allocator, coord);
                    tempStorage.clearRetainingCapacity();
                    try tempStorage.put(coord, void{});
                    const burned = try igniteBarrels(grid, &queue, &tempStorage, &result, xDim, yDim, allocator);
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
        _ = try igniteBarrels(grid, &queue, &result, &empty, xDim, yDim, allocator);

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

fn igniteBarrels(grid: *[210][210]u8, queue: *std.Deque(UCoord), burned: *std.AutoHashMap(UCoord, void), barrelsToIgnore: *const std.AutoHashMap(UCoord, void), xDim: usize, yDim: usize, allocator: Allocator) !u32 {
    while(queue.popBack()) |coord| {
        if(coord.y > 0 and grid[coord.x][coord.y-1] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x, .y = coord.y - 1};
            if(!burned.contains(new) and !barrelsToIgnore.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.y < yDim - 1 and grid[coord.x][coord.y+1] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x, .y = coord.y + 1};
            if(!burned.contains(new) and !barrelsToIgnore.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.x > 0 and grid[coord.x-1][coord.y] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x - 1, .y = coord.y};
            if(!burned.contains(new) and !barrelsToIgnore.contains(new)) {
                try burned.put(new, void{});
                try queue.pushFront(allocator, new);
            }
        }
        if(coord.x < xDim - 1 and grid[coord.x+1][coord.y] <= grid[coord.x][coord.y]) {
            const new = UCoord{.x = coord.x + 1, .y = coord.y};
            if(!burned.contains(new) and !barrelsToIgnore.contains(new)) {
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

const Range = struct {
    start: u32,
    end: u32,
    asc: bool,

    fn size(self: *const Range) u32 {
        if(self.asc) {
            return self.end - self.start + 1;
        } else {
            return self.start - self.end + 1;
        }
    }
};
