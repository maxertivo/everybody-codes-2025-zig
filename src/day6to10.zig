const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day6(a: Allocator) ![3]u64 {
    var arena = std.heap.ArenaAllocator.init(a);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file: fs.File = try fs.cwd().openFile(
        "src/inputs/day6.txt",
        .{},
    );
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);
    var line = readLine(&reader.interface) orelse return error.invalid;
    var aNum: u32 = 0;
    var part1: u32 = 0;
    for (line) |char| {
        switch (char) {
            'A' => aNum += 1,
            'a' => part1 += aNum,
            else => {},
        }
    }

    line = readLine(&reader.interface) orelse return error.invalid;
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

    line = readLine(&reader.interface) orelse return error.invalid;
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

pub fn day7(a: Allocator) ![3][20]u8 {
    var arena = std.heap.ArenaAllocator.init(a);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file: fs.File = try fs.cwd().openFile(
        "src/inputs/day7.txt",
        .{},
    );
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);
    var nameLine = readLine(&reader.interface) orelse return error.invalid;
    var multimap = utils.Multimap(u8, u8).init(allocator);
    var stringList = try parseStringList(allocator, nameLine);
    _ = readLine(&reader.interface);
    while (true) {
        const line = readLine(&reader.interface) orelse break;
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

    nameLine = readLine(&reader.interface) orelse return error.invalid;
    multimap = utils.Multimap(u8, u8).init(allocator);
    stringList = try parseStringList(allocator, nameLine);
    _ = readLine(&reader.interface);
    while (true) {
        const line = readLine(&reader.interface) orelse break;
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

    nameLine = readLine(&reader.interface) orelse return error.invalid;
    multimap = utils.Multimap(u8, u8).init(allocator);
    stringList = try parseStringList(allocator, nameLine);
    _ = readLine(&reader.interface);
    while (true) {
        const line = readLine(&reader.interface) orelse break;
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

const Count = struct {
    a: u32,
    b: u32,
    c: u32,
};
