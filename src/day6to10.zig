const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day6(allocator: Allocator, reader: *Reader) ![3]u64 {
    var line = readLine(reader) orelse return error.invalid;
    var aNum: u32 = 0;
    var part1: u32 = 0;
    for (line) |char| {
        switch (char) {
            'A' => aNum += 1,
            'a' => part1 += aNum,
            else => {},
        }
    }

    line = readLine(reader) orelse return error.invalid;
    aNum = 0;
    var bNum: u32 = 0;
    var cNum: u32 = 0;
    var part2: u32 = 0;
    for (line) |char| {
        switch (char) {
            'A' => aNum += 1,
            'B' => bNum += 1,
            'C' => cNum += 1,
            'a' => part2 += aNum,
            'b' => part2 += bNum,
            'c' => part2 += cNum,
            else => {},
        }
    }

    line = readLine(reader) orelse return error.invalid;
    const DIST = 1000;
    const fullArray = try allocator.alloc(u8, line.len * 3);
    std.mem.copyForwards(u8, fullArray, line);
    std.mem.copyForwards(u8, fullArray[line.len..], line);
    std.mem.copyForwards(u8, fullArray[line.len * 2 ..], line);
    var rearRange = try utils.ArrayDeque(u8).initWithCapacity(allocator, DIST + 1);
    var frontRange = try utils.ArrayDeque(u8).initWithCapacity(allocator, DIST + 1);
    var rearCount = Count{ .a = 0, .b = 0, .c = 0 };
    var frontCount = Count{ .a = 0, .b = 0, .c = 0 };
    var count: u64 = 0;
    var middleCount: u64 = 0;

    // Fill front range
    for (0..DIST) |i| {
        frontRange.addLast(fullArray[i]);
        switch (fullArray[i]) {
            'A' => frontCount.a += 1,
            'B' => frontCount.b += 1,
            'C' => frontCount.c += 1,
            else => {},
        }
    }

    // Fill rear range
    for (0..DIST) |i| {
        const cur = frontRange.popFirst().?;
        switch (cur) {
            'A' => frontCount.a -= 1,
            'B' => frontCount.b -= 1,
            'C' => frontCount.c -= 1,
            else => {},
        }
        frontRange.addLast(fullArray[i + DIST]);
        switch (fullArray[i + DIST]) {
            'A' => frontCount.a += 1,
            'B' => frontCount.b += 1,
            'C' => frontCount.c += 1,
            else => {},
        }

        switch (cur) {
            'a' => count += frontCount.a + rearCount.a,
            'b' => count += frontCount.b + rearCount.b,
            'c' => count += frontCount.c + rearCount.c,
            else => {},
        }

        rearRange.addLast(cur);
        switch (cur) {
            'A' => rearCount.a += 1,
            'B' => rearCount.b += 1,
            'C' => rearCount.c += 1,
            else => {},
        }
    }

    // Complete the first full iteration of the input
    for (DIST..line.len) |i| {
        const cur = frontRange.popFirst().?;
        switch (cur) {
            'A' => frontCount.a -= 1,
            'B' => frontCount.b -= 1,
            'C' => frontCount.c -= 1,
            else => {},
        }
        frontRange.addLast(fullArray[i + DIST]);
        switch (fullArray[i + DIST]) {
            'A' => frontCount.a += 1,
            'B' => frontCount.b += 1,
            'C' => frontCount.c += 1,
            else => {},
        }

        switch (cur) {
            'a' => count += frontCount.a + rearCount.a,
            'b' => count += frontCount.b + rearCount.b,
            'c' => count += frontCount.c + rearCount.c,
            else => {},
        }

        rearRange.addLast(cur);
        switch (cur) {
            'A' => rearCount.a += 1,
            'B' => rearCount.b += 1,
            'C' => rearCount.c += 1,
            else => {},
        }
        const prev = rearRange.popFirst().?;
        switch (prev) {
            'A' => rearCount.a -= 1,
            'B' => rearCount.b -= 1,
            'C' => rearCount.c -= 1,
            else => {},
        }
    }

    // Complete the second full iteration (this will be repeated 998 times)
    for (line.len..line.len * 2) |i| {
        const cur = frontRange.popFirst().?;
        switch (cur) {
            'A' => frontCount.a -= 1,
            'B' => frontCount.b -= 1,
            'C' => frontCount.c -= 1,
            else => {},
        }
        frontRange.addLast(fullArray[i + DIST]);
        switch (fullArray[i + DIST]) {
            'A' => frontCount.a += 1,
            'B' => frontCount.b += 1,
            'C' => frontCount.c += 1,
            else => {},
        }

        switch (cur) {
            'a' => middleCount += frontCount.a + rearCount.a,
            'b' => middleCount += frontCount.b + rearCount.b,
            'c' => middleCount += frontCount.c + rearCount.c,
            else => {},
        }

        rearRange.addLast(cur);
        switch (cur) {
            'A' => rearCount.a += 1,
            'B' => rearCount.b += 1,
            'C' => rearCount.c += 1,
            else => {},
        }
        const prev = rearRange.popFirst().?;
        switch (prev) {
            'A' => rearCount.a -= 1,
            'B' => rearCount.b -= 1,
            'C' => rearCount.c -= 1,
            else => {},
        }
    }

    // Complete the final iteration of the input (front range will shrink to empty at the end)
    for (line.len * 2..line.len * 3) |i| {
        const cur = frontRange.popFirst().?;
        switch (cur) {
            'A' => frontCount.a -= 1,
            'B' => frontCount.b -= 1,
            'C' => frontCount.c -= 1,
            else => {},
        }
        if (i + DIST < fullArray.len) {
            frontRange.addLast(fullArray[i + DIST]);
            switch (fullArray[i + DIST]) {
                'A' => frontCount.a += 1,
                'B' => frontCount.b += 1,
                'C' => frontCount.c += 1,
                else => {},
            }
        }

        switch (cur) {
            'a' => count += frontCount.a + rearCount.a,
            'b' => count += frontCount.b + rearCount.b,
            'c' => count += frontCount.c + rearCount.c,
            else => {},
        }

        rearRange.addLast(cur);
        switch (cur) {
            'A' => rearCount.a += 1,
            'B' => rearCount.b += 1,
            'C' => rearCount.c += 1,
            else => {},
        }
        const prev = rearRange.popFirst().?;
        switch (prev) {
            'A' => rearCount.a -= 1,
            'B' => rearCount.b -= 1,
            'C' => rearCount.c -= 1,
            else => {},
        }
    }

    return [3]u64{ part1, part2, count + 998 * middleCount };
}

pub fn day7(allocator: Allocator, reader: *Reader) ![3][20]u8 {
    var nameLine = readLine(reader) orelse return error.invalid;
    var multimap = utils.Multimap(u8, u8).init(allocator);
    var stringList = try parseStringList(allocator, nameLine);
    _ = readLine(reader);
    while (true) {
        const line = readLine(reader) orelse break;
        if (line.len == 0) {
            break;
        }
        const char = line[0];
        var iter = std.mem.tokenizeScalar(u8, line[4..], ',');
        while (iter.next()) |next| {
            try multimap.put(char, next[0]);
        }
    }

    var str1: [20]u8 = @splat(0);
    for (stringList.items) |item| {
        if (isStrValid(item, &multimap)) {
            std.mem.copyForwards(u8, &str1, item);
            break;
        }
    }

    nameLine = readLine(reader) orelse return error.invalid;
    multimap = utils.Multimap(u8, u8).init(allocator);
    stringList = try parseStringList(allocator, nameLine);
    _ = readLine(reader);
    while (true) {
        const line = readLine(reader) orelse break;
        if (line.len == 0) {
            break;
        }
        const char = line[0];
        var iter = std.mem.tokenizeScalar(u8, line[4..], ',');
        while (iter.next()) |next| {
            try multimap.put(char, next[0]);
        }
    }

    var result2: u64 = 0;
    for (0..stringList.items.len) |i| {
        const item = stringList.items[i];
        if (isStrValid(item, &multimap)) {
            result2 += i + 1;
        }
    }
    var str2: [20]u8 = @splat(0);
    _ = try std.fmt.bufPrint(&str2, "{d}", .{result2});

    nameLine = readLine(reader) orelse return error.invalid;
    multimap = utils.Multimap(u8, u8).init(allocator);
    stringList = try parseStringList(allocator, nameLine);
    _ = readLine(reader);
    while (true) {
        const line = readLine(reader) orelse break;
        if (line.len == 0) {
            break;
        }
        const char = line[0];
        var iter = std.mem.tokenizeScalar(u8, line[4..], ',');
        while (iter.next()) |next| {
            try multimap.put(char, next[0]);
        }
    }

    // Remove substrings
    var found = true;
    while (found) {
        found = false;
        outer: for (0..stringList.items.len) |i| {
            for (0..stringList.items.len) |j| {
                if (i == j) {
                    continue;
                }
                if (std.mem.startsWith(u8, stringList.items[i], stringList.items[j])) {
                    _ = stringList.swapRemove(i);
                    found = true;
                    break :outer;
                }
            }
        }
    }

    var result3: u32 = 0;
    var resultCache = std.AutoHashMap(u16, u32).init(allocator);
    for (stringList.items) |item| {
        if (isStrValid(item, &multimap)) {
            result3 += findAllValidStrings(@intCast(item.len), &multimap, item[item.len - 1], &resultCache);
        }
    }

    var str3: [20]u8 = @splat(0);
    _ = try std.fmt.bufPrint(&str3, "{d}", .{result3});

    return [3][20]u8{ str1, str2, str3 };
}

pub fn day8(allocator: Allocator, reader: *Reader) ![3]u32 {
    const line1 = readLine(reader) orelse return error.invalid;

    const NAILS = 32;
    var sequence1 = std.ArrayList(i8).empty;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while (it.next()) |next| {
        const val = try std.fmt.parseInt(i8, next, 10);
        try sequence1.append(allocator, val);
    }
    var part1: u32 = 0;
    for (0..sequence1.items.len - 1) |i| {
        if (@abs(sequence1.items[i + 1] - sequence1.items[i]) == NAILS / 2) {
            part1 += 1;
        }
    }

    const line2 = readLine(reader) orelse return error.invalid;
    var sequence2 = std.ArrayList(u32).empty;
    it = std.mem.tokenizeScalar(u8, line2, ',');
    while (it.next()) |next| {
        const val = try std.fmt.parseInt(u32, next, 10);
        try sequence2.append(allocator, val);
    }
    var threads = std.ArrayList(Thread).empty;
    for (0..sequence2.items.len - 1) |i| {
        try threads.append(allocator, .{ .a = sequence2.items[i], .b = sequence2.items[i + 1] });
    }
    var part2: u32 = 0;
    for (0..threads.items.len) |i| {
        const thread = threads.items[i];
        const min = @min(thread.a, thread.b);
        const max = @max(thread.a, thread.b);
        for (0..i) |j| {
            const thread2 = threads.items[j];
            const a2 = thread2.a;
            const b2 = thread2.b;
            if (a2 > min and a2 < max and (b2 < min or b2 > max)) {
                part2 += 1;
            } else if (b2 > min and b2 < max and (a2 < min or a2 > max)) {
                part2 += 1;
            }
        }
    }

    const line3 = readLine(reader) orelse return error.invalid;
    var sequence3 = std.ArrayList(u32).empty;
    it = std.mem.tokenizeScalar(u8, line3, ',');
    while (it.next()) |next| {
        const val = try std.fmt.parseInt(u32, next, 10);
        try sequence3.append(allocator, val);
    }
    threads.clearRetainingCapacity();
    for (0..sequence3.items.len - 1) |i| {
        // Convert to 0-indexed
        try threads.append(allocator, .{ .a = sequence3.items[i] - 1, .b = sequence3.items[i + 1] - 1 });
    }
    var part3: u32 = 0;
    const NAILS3 = 256;
    const RANGE = 15;
    for (0..NAILS3 / 2) |i| {
        for (i + NAILS3 / 2 - RANGE..i + NAILS3 / 2 + RANGE) |j| {
            var jCopy = j;
            if (jCopy >= NAILS3) {
                jCopy -= NAILS3;
            }
            const min = @min(i, jCopy);
            const max = @max(i, jCopy);
            var count: u32 = 0;
            for (0..threads.items.len) |k| {
                const thread = threads.items[k];
                const a2 = thread.a;
                const b2 = thread.b;
                if (a2 > min and a2 < max and (b2 < min or b2 > max)) {
                    count += 1;
                } else if (b2 > min and b2 < max and (a2 < min or a2 > max)) {
                    count += 1;
                } else if (a2 == min and b2 == max or a2 == max and b2 == min) {
                    count += 1;
                }
            }
            if (count > part3) {
                part3 = count;
            }
        }
    }
    return [3]u32{ part1, part2, part3 };
}

pub fn day9(allocator: Allocator, reader: *Reader) ![3]u32 {
    const line1 = readLine(reader).?[2..];
    const line2 = readLine(reader).?[2..];
    const line3 = readLine(reader).?[2..];
    const int1 = convertToInt(line1);
    const int2 = convertToInt(line2);
    const int3 = convertToInt(line3);

    var result1 = findSimilarity(int1, int2, int3);
    if (result1 == null) {
        result1 = findSimilarity(int2, int1, int3);
    }
    if (result1 == null) {
        result1 = findSimilarity(int3, int1, int2);
    }

    _ = readLine(reader);

    var scales = std.ArrayList(u512).empty;
    while (readLine(reader)) |line| {
        if (line.len == 0) {
            break;
        }
        const start = std.mem.indexOfScalar(u8, line, ':').?;
        const slice = line[start + 1 ..];
        try scales.append(allocator, convertToInt(slice));
    }

    var result2: u32 = 0;
    for (0..scales.items.len) |i| {
        const similarity = findParentsAndSimilarity(scales.items, i);
        if (similarity) |s| {
            result2 += s;
        }
    }

    scales = std.ArrayList(u512).empty;
    while (readLine(reader)) |line| {
        if (line.len == 0) {
            break;
        }
        const start = std.mem.indexOfScalar(u8, line, ':').?;
        const slice = line[start + 1 ..];
        try scales.append(allocator, convertToInt(slice));
    }

    var allConnections = utils.Multimap(u32, u32).init(allocator);
    for (0..scales.items.len) |i| {
        const start: u32 = @intCast(i + 1);
        const parentsOptional = findParents(scales.items, i);
        if (parentsOptional) |parents| {
            try allConnections.put(start, parents[0]);
            try allConnections.put(start, parents[1]);
            try allConnections.put(parents[0], start);
            try allConnections.put(parents[1], start);
            try allConnections.put(parents[0], parents[1]);
            try allConnections.put(parents[1], parents[0]);
        }
    }

    var scaleSet = std.AutoHashMap(u32, void).init(allocator);
    var fullScaleSet = std.AutoHashMap(u32, void).init(allocator);
    var deque = try std.Deque(u32).initCapacity(allocator, 50);
    var maxCount: u32 = 0;
    var result3: u32 = 0;
    for (0..scales.items.len) |i| {
        const startingChild: u32 = @intCast(i + 1);
        if (fullScaleSet.contains(startingChild)) {
            continue;
        }
        deque.pushBackAssumeCapacity(startingChild);
        try scaleSet.put(startingChild, void{});
        while (deque.popFront()) |node| {
            const connections = allConnections.get(node);
            for (connections) |connection| {
                if (!scaleSet.contains(connection)) {
                    try scaleSet.put(connection, void{});
                    deque.pushBackAssumeCapacity(connection);
                }
            }
        }
        std.debug.assert(deque.len == 0);
        var sum: u32 = 0;
        var it = scaleSet.keyIterator();
        while (it.next()) |key| {
            try fullScaleSet.put(key.*, void{});
            sum += key.*;
        }
        if (scaleSet.count() > maxCount) {
            maxCount = scaleSet.count();
            result3 = sum;
        }
        scaleSet.clearRetainingCapacity();
    }

    return [3]u32{ result1.?, result2, result3 };
}

pub fn day10(allocator: Allocator, reader: *Reader) ![3]u64 {
    var sheep = std.AutoHashMap(Coord, void).init(allocator);
    var hideouts = std.AutoHashMap(Coord, void).init(allocator);
    var start, var dimX, var dimY = try readMap(reader, &sheep, &hideouts);
    var result1: u32 = 0;
    var set1 = std.AutoHashMap(Coord, void).init(allocator);
    var set2 = std.AutoHashMap(Coord, void).init(allocator);
    try set1.put(start, void{});
    for (0..2) |_| {
        try populateReachable(&set2, &set1, @abs(dimX), @abs(dimY));
        var it = set2.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*)) {
                result1 += 1;
                _ = sheep.remove(key.*);
            }
        }
        try populateReachable(&set1, &set2, @abs(dimX), @abs(dimY));
        it = set1.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*)) {
                result1 += 1;
                _ = sheep.remove(key.*);
            }
        }
    }

    sheep.clearRetainingCapacity();
    hideouts.clearRetainingCapacity();
    start, dimX, dimY = try readMap(reader, &sheep, &hideouts);
    set1.clearRetainingCapacity();
    set2.clearRetainingCapacity();
    try set1.put(start, void{});
    var result2: u32 = 0;
    var count: u8 = 0;
    while (count < 10) {
        try populateReachable(&set2, &set1, @abs(dimX), @abs(dimY));
        var it = set2.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*) and !hideouts.contains(key.*)) {
                result2 += 1;
                _ = sheep.remove(key.*);
            }
        }
        try updateSheep(allocator, &sheep, dimY);
        it = set2.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*) and !hideouts.contains(key.*)) {
                result2 += 1;
                _ = sheep.remove(key.*);
            }
        }

        try populateReachable(&set1, &set2, @abs(dimX), @abs(dimY));
        it = set1.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*) and !hideouts.contains(key.*)) {
                result2 += 1;
                _ = sheep.remove(key.*);
            }
        }
        try updateSheep(allocator, &sheep, dimY);
        it = set1.keyIterator();
        while (it.next()) |key| {
            if (sheep.contains(key.*) and !hideouts.contains(key.*)) {
                result2 += 1;
                _ = sheep.remove(key.*);
            }
        }
        count += 1;
    }

    sheep.clearRetainingCapacity();
    hideouts.clearRetainingCapacity();
    start, dimX, dimY = try readMap(reader, &sheep, &hideouts);
    var sheepKey: u49 = 0;
    var it = sheep.keyIterator();
    while (it.next()) |key| {
        const bit: u6 = @intCast(key.*.y * dimX + key.*.x);
        sheepKey += (@as(u49, 1) << bit);
    }
    const dragonStart: u7 = @intCast(start.y * dimX + start.x);
    const initialState = State{ .sheep = sheepKey, .dragon = dragonStart, .dragonTurn = false };
    var stateToCountMap = std.AutoHashMap(u64, u64).init(allocator);
    const result3 = try getOrCalculate(initialState, &stateToCountMap, convertHideouts(&hideouts, dimX), dimX, dimY, allocator);

    return [3]u64{ result1, result2, result3 };
}

fn convertHideouts(hideouts: *std.AutoHashMap(Coord, void), dimX: i32) u49 {
    var it = hideouts.keyIterator();
    var result: u49 = 0;
    while (it.next()) |key| {
        const bit: u6 = @intCast(key.*.y * dimX + key.*.x);
        result += (@as(u49, 1) << bit);
    }
    return result;
}

fn getOrCalculate(state: State, stateToCountMap: *std.AutoHashMap(u64, u64), hideouts: u49, dimX: i32, dimY: i32, allocator: Allocator) !u64 {
    if (stateToCountMap.get(@bitCast(state))) |count| {
        return count;
    }
    var result: u64 = 0;
    const states = try getNextStates(state, hideouts, dimX, dimY, allocator);
    for (states.items) |newState| {
        if (newState.sheep == 0) {
            result += 1;
        } else {
            const evaluatedState = try getOrCalculate(newState, stateToCountMap, hideouts, dimX, dimY, allocator);
            try stateToCountMap.put(@bitCast(newState), evaluatedState);
            result += evaluatedState;
        }
    }
    return result;
}

fn getNextStates(state: State, hideouts: u49, dimX: i32, dimY: i32, allocator: Allocator) !std.ArrayList(State) {
    var list = std.ArrayList(State).empty;
    const sheep = state.sheep;
    const c = Coord{ .x = @mod(state.dragon, @as(u7, @intCast(dimX))), .y = @divFloor(state.dragon, @as(u7, @intCast(dimX))) };
    if (state.dragonTurn) {
        if (inbounds(c.x - 2, c.y - 1, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x - 2, .y = c.y - 1 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x - 2, c.y + 1, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x - 2, .y = c.y + 1 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x - 1, c.y - 2, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x - 1, .y = c.y - 2 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x - 1, c.y + 2, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x - 1, .y = c.y + 2 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x + 1, c.y - 2, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x + 1, .y = c.y - 2 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x + 1, c.y + 2, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x + 1, .y = c.y + 2 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x + 2, c.y - 1, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x + 2, .y = c.y - 1 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        if (inbounds(c.x + 2, c.y + 1, @abs(dimX), @abs(dimY))) {
            const next = Coord{ .x = c.x + 2, .y = c.y + 1 };
            const nextInt: u7 = @intCast(next.y * dimX + next.x);
            const nextSheep = checkSheep(next, sheep, hideouts, dimX);
            try list.append(allocator, .{ .sheep = nextSheep, .dragon = nextInt, .dragonTurn = false });
        }
        return list;
    } else {
        var sheepCopy = state.sheep;
        var hideoutsCopy = hideouts;
        const dimXCast: u6 = @intCast(dimX);
        var allWaitingForDragon = true;
        for (0..49) |i| {
            const bit: u6 = @intCast(i);
            const bitSigned: i32 = @intCast(i);
            if (sheepCopy & 1 == 1) {
                const x = @mod(bitSigned, dimX);
                const y = @divFloor(bitSigned, dimX);
                const oldSheep = @as(u49, 1) << bit;
                const newSheep = @as(u49, 1) << (bit + dimXCast);
                const nextSheep = state.sheep - oldSheep + newSheep;
                if (((c.x != x or c.y != y + 1) or (hideoutsCopy >> dimXCast) & 1 == 1) and y + 1 < dimY) {
                    try list.append(allocator, .{ .sheep = nextSheep, .dragon = state.dragon, .dragonTurn = true });
                } else if (y + 1 >= dimY) {
                    allWaitingForDragon = false;
                }
            }
            sheepCopy >>= 1;
            hideoutsCopy >>= 1;
        }
        if (list.items.len == 0 and allWaitingForDragon) {
            try list.append(allocator, .{ .sheep = state.sheep, .dragon = state.dragon, .dragonTurn = true });
        }
    }
    return list;
}

fn checkSheep(dragon: Coord, sheep: u49, hideouts: u49, dimX: i32) u49 {
    const bit: u6 = @intCast(dragon.y * dimX + dragon.x);
    const mask: u49 = ~(@as(u49, 1) << bit) | hideouts;
    return sheep & mask;
}

fn updateSheep(allocator: Allocator, sheep: *std.AutoHashMap(Coord, void), dim: i32) !void {
    var it = sheep.keyIterator();
    var list = std.ArrayList(Coord).empty;
    while (it.next()) |key| {
        try list.append(allocator, key.*);
    }
    sheep.clearRetainingCapacity();
    for (list.items) |item| {
        if (item.y < dim - 1) {
            try sheep.put(.{ .x = item.x, .y = item.y + 1 }, void{});
        }
    }
}

fn readMap(reader: *Reader, sheep: *std.AutoHashMap(Coord, void), hideouts: *std.AutoHashMap(Coord, void)) !struct { Coord, i32, i32 } {
    var start = Coord{ .x = 0, .y = 0 };
    var y1: i32 = 0;
    var x1: i32 = 0;
    while (readLine(reader)) |line| {
        if (line.len == 0) {
            break;
        }
        x1 = 0;
        for (line) |char| {
            if (char == 'S') {
                try sheep.put(.{ .x = x1, .y = y1 }, void{});
            }
            if (char == '#') {
                try hideouts.put(.{ .x = x1, .y = y1 }, void{});
            }
            if (char == 'D') {
                start = .{ .x = x1, .y = y1 };
            }
            x1 += 1;
        }
        y1 += 1;
    }
    return .{ start, x1, y1 };
}

fn populateReachable(result: *std.AutoHashMap(Coord, void), input: *std.AutoHashMap(Coord, void), dimX: u32, dimY: u32) !void {
    var it = input.keyIterator();
    while (it.next()) |coord| {
        const c = coord.*;
        if (inbounds(c.x - 2, c.y - 1, dimX, dimY)) {
            try result.put(.{ .x = c.x - 2, .y = c.y - 1 }, void{});
        }
        if (inbounds(c.x - 2, c.y + 1, dimX, dimY)) {
            try result.put(.{ .x = c.x - 2, .y = c.y + 1 }, void{});
        }
        if (inbounds(c.x - 1, c.y - 2, dimX, dimY)) {
            try result.put(.{ .x = c.x - 1, .y = c.y - 2 }, void{});
        }
        if (inbounds(c.x - 1, c.y + 2, dimX, dimY)) {
            try result.put(.{ .x = c.x - 1, .y = c.y + 2 }, void{});
        }
        if (inbounds(c.x + 1, c.y - 2, dimX, dimY)) {
            try result.put(.{ .x = c.x + 1, .y = c.y - 2 }, void{});
        }
        if (inbounds(c.x + 1, c.y + 2, dimX, dimY)) {
            try result.put(.{ .x = c.x + 1, .y = c.y + 2 }, void{});
        }
        if (inbounds(c.x + 2, c.y - 1, dimX, dimY)) {
            try result.put(.{ .x = c.x + 2, .y = c.y - 1 }, void{});
        }
        if (inbounds(c.x + 2, c.y + 1, dimX, dimY)) {
            try result.put(.{ .x = c.x + 2, .y = c.y + 1 }, void{});
        }
    }
}

fn inbounds(x: i32, y: i32, dimX: u32, dimY: u32) bool {
    return x >= 0 and x < dimX and y >= 0 and y < dimY;
}

fn convertToInt(line: []const u8) u512 {
    var result: u512 = 0;
    for (0..128) |i| {
        result <<= 4;
        if (i >= line.len) {
            break;
        }
        const char = line[i];
        result += switch (char) {
            'A' => 0b0001,
            'G' => 0b0010,
            'T' => 0b0100,
            'C' => 0b1000,
            else => unreachable,
        };
    }

    return result;
}

fn findParents(scales: []u512, childIndex: usize) ?[2]u32 {
    const child = scales[childIndex];
    for (0..scales.len) |j| {
        if (j == childIndex) {
            continue;
        }
        for (j + 1..scales.len) |k| {
            if (k == childIndex) {
                continue;
            }
            if (isParents(child, scales[j], scales[k])) {
                return [2]u32{ @intCast(j + 1), @intCast(k + 1) };
            }
        }
    }
    return null;
}

fn findParentsAndSimilarity(scales: []u512, childIndex: usize) ?u32 {
    const child = scales[childIndex];
    for (0..scales.len) |j| {
        if (j == childIndex) {
            continue;
        }
        for (j + 1..scales.len) |k| {
            if (k == childIndex) {
                continue;
            }
            if (findSimilarity(child, scales[j], scales[k])) |result| {
                return result;
            }
        }
    }
    return null;
}

fn findSimilarity(c: u512, p1: u512, p2: u512) ?u32 {
    if (!isParents(c, p1, p2)) {
        return null;
    }

    return @as(u32, @popCount(c & p1)) * @as(u32, @popCount(c & p2));
}

fn isParents(c: u512, p1: u512, p2: u512) bool {
    return (c & (p1 | p2) == c);
}

fn findAllValidStrings(size: u8, multimap: *utils.Multimap(u8, u8), lastChar: u8, resultCache: *std.AutoHashMap(u16, u32)) u32 {
    var sum: u32 = 0;
    for (multimap.get(lastChar)) |possibleChar| {
        const newSize = size + 1;
        if (newSize >= 7 and newSize <= 11) {
            sum += 1;
        }
        if (newSize < 11) {
            var key: u16 = newSize;
            key <<= 8;
            key += possibleChar;
            if (resultCache.get(key)) |cached| {
                sum += cached;
            } else {
                const result = findAllValidStrings(newSize, multimap, possibleChar, resultCache);
                sum += result;
                resultCache.put(key, result) catch std.debug.print("Failed to cache\n", .{});
            }
        }
    }
    return sum;
}

fn parseStringList(allocator: Allocator, nameLine: []const u8) !std.ArrayList([]u8) {
    var list = std.ArrayList([]u8).empty;
    var it = std.mem.tokenizeScalar(u8, nameLine, ',');
    while (it.next()) |next| {
        const copy = try allocator.dupe(u8, next);
        try list.append(allocator, copy);
    }
    return list;
}

fn isStrValid(string: []u8, multimap: *utils.Multimap(u8, u8)) bool {
    for (0..string.len - 1) |i| {
        var charValid = false;
        const validList = multimap.get(string[i]);
        for (validList) |ch| {
            if (string[i + 1] == ch) {
                charValid = true;
                break;
            }
        }
        if (!charValid) {
            return false;
        }
    }
    return true;
}

const State = packed struct {
    sheep: u49, // This supports a 7x7 grid maximum. Top left corner is rightmost bit. Bottom right is leftmost.
    dragon: u7, // Supports 64 squares. More than needed
    dragonTurn: bool,
    _: u7 = 0,
};

const Count = struct {
    a: u32,
    b: u32,
    c: u32,
};

const Thread = struct {
    a: u32,
    b: u32,
};

const Tile = enum { EMPTY, SHEEP };

const Coord = struct { x: i32, y: i32 };
