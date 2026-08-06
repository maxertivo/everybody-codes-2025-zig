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

pub fn day15(allocator: Allocator, reader: *Reader) ![3]u64 {
    const instructions = try parseInstructions(allocator, reader);

    const walls, const end = try getWalls(instructions, allocator);
    const context = AStarContext{.walls = &walls, .start = .{.x = 0, .y = 0}, .end = end};
    const initialState = Coord{.x = 0, .y = 0};
    const cost1 = utils.aStarAuto(Coord, u32, AStarContext, nextStateFn, transitionCostFn, estimateFn, isSolutionFn, initialState, context, allocator).?;

    _ = readLine(reader);
    const instructions2 = try parseInstructions(allocator, reader);
    const context2 = try getContext(instructions2, allocator);
    const cost2 = utils.aStarAuto(Coord, u32, AStarContext2, nextStateFn2, transitionCostFn2, estimateFn2, isSolutionFn2, initialState, context2, allocator).?;

    _ = readLine(reader);
    const instructions3 = try parseInstructions(allocator, reader);
    const context3 = try getContext(instructions3, allocator);
    const cost3 = utils.aStarAuto(Coord, u32, AStarContext2, nextStateFn2, transitionCostFn2, estimateFn2, isSolutionFn2, initialState, context3, allocator).?;
    return [3]u64{cost1, cost2, cost3};
}

fn getContext(instructions: std.ArrayList(Instruction), allocator: Allocator) !AStarContext2 {
    var segments = try allocator.create(std.ArrayList(LineSegment));
    segments.* = std.ArrayList(LineSegment).empty;
    var xCoords = std.AutoHashMap(i32, void).init(allocator);
    var yCoords = std.AutoHashMap(i32, void).init(allocator);

    var dir = Direction.U;
    var coord = Coord{.x = 0, .y = 0};

    // Construct the wall segments and create a list of x and y coordinates that may need to be visited
    // The key insight here is that we only care about x and y coordinates that are:
    // 1. At the tips of walls (so we can go around them)
    // 2. Next to the sides of walls (so we will be able to run all the way up to them)
    for(instructions.items, 0..) |instruction, i| {
        const oldDir = dir;
        dir = dir.changeDirection(instruction.dir);

        // The original starting coord is not part of a wall segment, so shift one unit
        const start = if(i == 0) coord.moveDir(dir) else coord;
        // The final ending coord is not part of a wall segment, so shift one unit
        const end = coord.moveDirAmount(dir, if (i == instructions.items.len - 1) instruction.steps - 1 else instruction.steps);

        // Add the x and y coords one unit away from the wall
        if(dir == Direction.L or dir == Direction.R) {
            try xCoords.put(end.moveDir(dir).x, void{});
            try xCoords.put(start.moveDir(dir.getOpposite()).x, void{});
            try yCoords.put(start.moveDir(oldDir).y, void{});
            try yCoords.put(start.moveDir(oldDir.getOpposite()).y, void{});
        } else {
            try yCoords.put(end.moveDir(dir).y, void{});
            try yCoords.put(start.moveDir(dir.getOpposite()).y, void{});
            try xCoords.put(start.moveDir(oldDir).x, void{});
            try xCoords.put(start.moveDir(oldDir).x, void{});
        }
        try segments.append(allocator, .{.start = start, .end = end});
        coord = end;
        if(i == instructions.items.len - 1) {
            // 'end' was shifted to avoid it being the destination. This undoes that shift so coord is the destination.
            coord = coord.moveDir(dir);
        }
    }

    // The start and end position must be valid x and y coordinates (so we can travel to / from them)
    try xCoords.put(0, void{});
    try xCoords.put(coord.x, void{});
    try yCoords.put(0, void{});
    try yCoords.put(coord.y, void{});

    var xCoordList = try allocator.create(std.ArrayList(i32));
    xCoordList.* = std.ArrayList(i32).empty;
    var it = xCoords.keyIterator();
    while(it.next()) |x| {
        try xCoordList.append(allocator, x.*);
    }
    var yCoordList = try allocator.create(std.ArrayList(i32));
    yCoordList.* = std.ArrayList(i32).empty;
    it = yCoords.keyIterator();
    while(it.next()) |y| {
        try yCoordList.append(allocator, y.*);
    }
    std.mem.sort(i32, xCoordList.items, void{}, std.sort.asc(i32));
    std.mem.sort(i32, yCoordList.items, void{}, std.sort.asc(i32));
    return .{.segments = segments, .sortedXCoords = xCoordList, .sortedYCoords = yCoordList, .start = .{.x = 0, .y = 0}, .end = coord};
}

// Returns a Set of wall coordinates, and the destination coordinate
fn getWalls(instructions: std.ArrayList(Instruction), allocator: Allocator) !struct{std.AutoHashMap(Coord, void), Coord} {
    var walls = std.AutoHashMap(Coord, void).init(allocator);
    var dir = Direction.U;
    var coord = Coord{.x = 0, .y = 0};
    for(instructions.items) |instruction| {
        dir = dir.changeDirection(instruction.dir);
        for(0..instruction.steps) |_| {
            coord = coord.moveDir(dir);
            try walls.put(coord, void{});
        }
    }
    _ = walls.remove(coord);
    return .{walls, coord};
}

// Takes one step in each direction
fn nextStateFn(context: AStarContext, coord: Coord, allocator: Allocator) std.ArrayList(Coord) {
    var list = std.ArrayList(Coord).empty;
    const left = Coord{.x = coord.x - 1, .y = coord.y};
    const right = Coord{.x = coord.x + 1, .y = coord.y};
    const up = Coord{.x = coord.x, .y = coord.y + 1};
    const down = Coord{.x = coord.x, .y = coord.y - 1};
    if(!context.walls.contains(left)) {
        list.append(allocator, left) catch unreachable;
    }
    if(!context.walls.contains(right)) {
        list.append(allocator, right) catch unreachable;
    }
    if(!context.walls.contains(up)) {
        list.append(allocator, up) catch unreachable;
    }
    if(!context.walls.contains(down)) {
        list.append(allocator, down) catch unreachable;
    }
    return list;
}

// Go to neighboring x and y coordinates in the lists of valid coordinates.
// This allows the next state to be a large distance away, which is more efficient for mazes with long walls.
fn nextStateFn2(context: AStarContext2, coord: Coord, allocator: Allocator) std.ArrayList(Coord) {
    var list = std.ArrayList(Coord).empty;
    const xIndex = std.sort.binarySearch(i32, context.sortedXCoords.items, coord.x, compare).?;
    const xLower = if(xIndex > 0) context.sortedXCoords.items[xIndex - 1] else null;
    const xHigher = if(xIndex < context.sortedXCoords.items.len - 1) context.sortedXCoords.items[xIndex + 1] else null;
    const yIndex = std.sort.binarySearch(i32, context.sortedYCoords.items, coord.y, compare).?;
    const yLower = if(yIndex > 0) context.sortedYCoords.items[yIndex - 1] else null;
    const yHigher = if(yIndex < context.sortedYCoords.items.len - 1) context.sortedYCoords.items[yIndex + 1] else null;
    const left = if(xLower) |x| LineSegment{.start = coord, .end = Coord{.x = x, .y = coord.y}} else null;
    const right = if(xHigher) |x| LineSegment{.start = coord, .end = Coord{.x = x, .y = coord.y}} else null;
    const down = if(yLower) |y| LineSegment{.start = coord, .end = Coord{.x = coord.x, .y = y}} else null;
    const up = if(yHigher) |y| LineSegment{.start = coord, .end = Coord{.x = coord.x, .y = y}} else null;
    if(left != null and !intersectsAny(left.?, context.segments.items)) {
        list.append(allocator, left.?.end) catch unreachable;
    }
    if(right != null and !intersectsAny(right.?, context.segments.items)) {
        list.append(allocator, right.?.end) catch unreachable;
    }
    if(down != null and !intersectsAny(down.?, context.segments.items)) {
        list.append(allocator, down.?.end) catch unreachable;
    }
    if(up != null and !intersectsAny(up.?, context.segments.items)) {
        list.append(allocator, up.?.end) catch unreachable;
    }
    return list;
}

fn transitionCostFn(_: AStarContext, _: Coord, _: Coord) u32 {
    return 1;
}

fn transitionCostFn2(_: AStarContext2, a: Coord, b: Coord) u32 {
    return @abs(a.x - b.x) + @abs(a.y - b.y);
}

fn estimateFn(context: AStarContext, coord: Coord) u32 {
    return @abs(context.end.x - coord.x) + @abs(context.end.y - coord.y);
}

fn estimateFn2(context: AStarContext2, coord: Coord) u32 {
    return @abs(context.end.x - coord.x) + @abs(context.end.y - coord.y);
}

fn isSolutionFn(context: AStarContext, coord: Coord) bool {
    return coord.x == context.end.x and coord.y == context.end.y;
}

fn isSolutionFn2(context: AStarContext2, coord: Coord) bool {
    return coord.x == context.end.x and coord.y == context.end.y;
}

fn compare(context: i32, item: i32) std.math.Order {
    return std.math.order(context, item);
}

fn parseInstructions(allocator: Allocator, reader: *Reader) !std.ArrayList(Instruction) {
    const line = readLine(reader).?;
    var instructions = std.ArrayList(Instruction).empty;
    var it = std.mem.tokenizeScalar(u8, line, ',');
    while(it.next()) |next| {
        const dir = if(next[0] == 'L') DirectionChange.L else DirectionChange.R;
        const steps: u32 = try std.fmt.parseInt(u32, next[1..], 10);
        try instructions.append(allocator, .{.dir = dir, .steps = steps});
    }
    return instructions;
}

fn intersectsAny(line: LineSegment, list: []const LineSegment) bool {
    for(list) |item| {
        if(intersects(line, item)) {
            return true;
        }
    }
    return false;
}

fn intersects(line1: LineSegment, line2: LineSegment) bool {
    if (line1.start.x == line1.end.x and line2.start.x == line2.end.x) {
        if (line1.start.x != line2.start.x) {
            return false;
        }
        const lowest1 = @min(line1.start.y, line1.end.y);
        const lowest2 = @min(line2.start.y, line2.end.y);
        const highest1 = @max(line1.start.y, line1.end.y);
        const highest2 = @max(line2.start.y, line2.end.y);
        const start = @max(lowest1, lowest2);
        const end = @min(highest1, highest2);
        return start <= end;
    } else if (line1.start.y == line1.end.y and line2.start.y == line2.end.y) {
        if (line1.start.y != line2.start.y) {
            return false;
        }
        const lowest1 = @min(line1.start.x, line1.end.x);
        const lowest2 = @min(line2.start.x, line2.end.x);
        const highest1 = @max(line1.start.x, line1.end.x);
        const highest2 = @max(line2.start.x, line2.end.x);
        const start = @max(lowest1, lowest2);
        const end = @min(highest1, highest2);
        return start <= end;
    } else {
        const verticalLine = if (line1.start.x == line1.end.x) line1 else line2;
        const horizontalLine = if (line1.start.x == line1.end.x) line2 else line1;
        const x = verticalLine.start.x;
        const y = horizontalLine.start.y;
        const validX = (x <= horizontalLine.start.x and x >= horizontalLine.end.x) or (x <= horizontalLine.end.x and x >= horizontalLine.start.x);
        const validY = (y <= verticalLine.start.y and y >= verticalLine.end.y) or (y <= verticalLine.end.y and y >= verticalLine.start.y);
        return validX and validY;
    }
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

const Coord = struct {
    x: i32,
    y: i32,

    fn moveDir(coord: Coord, dir: Direction) Coord {
        return switch(dir) {
            Direction.U => .{.x = coord.x, .y = coord.y + 1},
            Direction.R => .{.x = coord.x + 1, .y = coord.y},
            Direction.D => .{.x = coord.x, .y = coord.y - 1},
            Direction.L => .{.x = coord.x - 1, .y = coord.y},
        };
    }

    fn moveDirAmount(coord: Coord, dir: Direction, steps: u32) Coord {
        return switch(dir) {
            Direction.U => .{.x = coord.x, .y = coord.y + @as(i32, @intCast(steps))},
            Direction.R => .{.x = coord.x + @as(i32, @intCast(steps)), .y = coord.y},
            Direction.D => .{.x = coord.x, .y = coord.y - @as(i32, @intCast(steps))},
            Direction.L => .{.x = coord.x - @as(i32, @intCast(steps)), .y = coord.y},
        };
    }
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

const DirectionChange = enum {
    L,
    R,
};

const Direction = enum {
    U,
    D,
    L,
    R,

    fn changeDirection(cur: Direction, change: DirectionChange) Direction {
        return switch(cur) {
            Direction.U => if(change == DirectionChange.L) Direction.L else Direction.R,
            Direction.R => if(change == DirectionChange.L) Direction.U else Direction.D,
            Direction.D => if(change == DirectionChange.L) Direction.R else Direction.L,
            Direction.L => if(change == DirectionChange.L) Direction.D else Direction.U,
        };
    }

    fn getOpposite(dir: Direction) Direction {
        return switch(dir) {
            Direction.U => Direction.D,
            Direction.R => Direction.L,
            Direction.D => Direction.U,
            Direction.L => Direction.R,
        };
    }
};

const Instruction = struct {
    dir: DirectionChange,
    steps: u32,
};

const AStarContext = struct {
    walls: *const std.AutoHashMap(Coord, void),
    start: Coord,
    end: Coord,
};

const AStarContext2 = struct {
    segments: *const std.ArrayList(LineSegment), // Wall segments
    sortedXCoords: *const std.ArrayList(i32),
    sortedYCoords: *const std.ArrayList(i32),
    start: Coord,
    end: Coord,
};

const LineSegment = struct {
    start: Coord,
    end: Coord,
};
