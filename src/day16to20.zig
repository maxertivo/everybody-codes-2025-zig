const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const fs = std.fs;

const readLine = utils.readLine;

const DIM1: usize = 40;
const DIM2: usize = 101;
const DIM3: usize = 160;
const VOLCANO_RATE = 30;

pub fn day16(allocator: Allocator, reader: *Reader) ![3]u64 {
    // Part 1
    var list = try parseNumberList(allocator, reader);
    var result1: u64 = 0;
    for (list.items) |item| {
        result1 += 90 / item;
    }

    // Part2
    _ = readLine(reader);
    list = try parseNumberList(allocator, reader);
    var spell = std.ArrayList(u32).empty;
    var result2: u64 = 1;
    for (list.items, 1..) |item, i| {
        const index: u32 = @intCast(i);
        if (spell.items.len == 0) {
            try spell.append(allocator, index);
        } else {
            var factors: u32 = 0;
            for (spell.items) |factor| {
                if (index % factor == 0) {
                    factors += 1;
                }
            }
            if (factors < item) {
                try spell.append(allocator, index);
            }
        }
    }
    for (spell.items) |item| {
        result2 *= item;
    }

    // Part3
    _ = readLine(reader);
    list = try parseNumberList(allocator, reader);
    spell = std.ArrayList(u32).empty;
    for (list.items, 1..) |item, i| {
        const index: u32 = @intCast(i);
        if (spell.items.len == 0) {
            try spell.append(allocator, index);
        } else {
            var factors: u32 = 0;
            for (spell.items) |factor| {
                if (index % factor == 0) {
                    factors += 1;
                }
            }
            if (factors < item) {
                try spell.append(allocator, index);
            }
        }
    }
    var lengthFactor: f64 = 0;
    for (spell.items) |item| {
        lengthFactor += 1 / @as(f64, item);
    }
    const totalBricks = 202520252025000;

    // This should be very close to the final answer
    var result3: u64 = @ceil(@as(f64, totalBricks) / lengthFactor);

    while (true) {
        var bricks: u64 = 0;
        for (spell.items) |item| {
            bricks += result3 / item;
        }
        if (bricks < totalBricks) {
            result3 += 1;
        } else {
            if (bricks > totalBricks) {
                result3 -= 1;
            }
            break;
        }
    }

    return [3]u64{ result1, result2, result3 };
}

pub fn day17(allocator: Allocator, reader: *Reader) ![3]u64 {
    const grid, const volcano, _ = parseGrid(DIM1, reader);

    const result1 = calculateDestruction(DIM1, &grid, volcano, 10);

    const grid2, const volcano2, _ = parseGrid(DIM2, reader);
    var filledDim = grid2[0].len;
    for (grid2[0], 0..) |val, x| {
        if (val == 0) {
            filledDim = x;
            break;
        }
    }
    const distToEdge = @min(volcano2.x, @min(volcano2.y, @min(filledDim - volcano2.x, filledDim - volcano2.y)));

    var prev: u64 = 0;
    var max: u64 = 0;
    var maxIndex: usize = 0;
    for (1..distToEdge) |i| {
        const cur = calculateDestruction(DIM2, &grid2, volcano2, i);
        const increase = cur - prev;
        if (increase > max) {
            max = increase;
            maxIndex = i;
        }
        prev = cur;
    }
    const result2 = maxIndex * max;

    const grid3, const volcano3, const loopStart3 = parseGrid(DIM3, reader);

    filledDim = grid3[0].len;
    for (grid3[0], 0..) |val, x| {
        if (val == 0) {
            filledDim = x;
            break;
        }
    }

    const initialState = AStarState{ .coord = loopStart3 };
    var radius: usize = 1;
    var result3: u32 = 0;
    // Increase radius until we can complete loop before volcano reaches radius
    while (true) {
        const context = AStarContext{ .grid = &grid3, .start = loopStart3, .volcano = volcano3, .radius = radius, .dim = filledDim };
        const time = utils.aStarAuto(AStarState, u32, AStarContext, nextStateFn, transitionCostFn, estimateFn, isSolutionFn, initialState, context, allocator).?;
        if (time / VOLCANO_RATE <= radius) {
            result3 = @intCast(time * radius);
            break; // We completed the loop with the volcano not exceeding radius
        }
        radius = time / VOLCANO_RATE + 2;
    }
    // Decrease radius until we can no longer complete the loop in time and use last success for answer
    while (true) {
        radius -= 1;
        const context = AStarContext{ .grid = &grid3, .start = loopStart3, .volcano = volcano3, .radius = radius, .dim = filledDim };
        const time = utils.aStarAuto(AStarState, u32, AStarContext, nextStateFn, transitionCostFn, estimateFn, isSolutionFn, initialState, context, allocator).?;
        if (time / VOLCANO_RATE > radius) {
            break; // We reduced the radius too much and can't make a loop in time
        } else {
            result3 = @intCast(time * radius);
        }
    }

    return [3]u64{ result1, result2, result3 };
}

pub fn day18(allocator: Allocator, reader: *Reader) ![3]i64 {
    const plantMap, _ = try createPlantMap(0, allocator, reader);
    const parent = try findParent(&plantMap);
    const result1 = calculateEnergy(32, &plantMap, parent, std.StaticBitSet(32).full);

    const plantMap2, const testCases2 = try createPlantMap(32, allocator, reader);
    const parent2 = try findParent(&plantMap2);
    var result2: i64 = 0;
    for(testCases2.items) |testCaseInput| {
        result2 += calculateEnergy(32, &plantMap2, parent2, testCaseInput);
    }

    const plantMap3, const testCases3 = try createPlantMap(128, allocator, reader);
    const parent3 = try findParent(&plantMap3);
    const maxInput = getMaxInput(&plantMap3);
    const maxResult = calculateEnergy(128, &plantMap3, parent3, maxInput);
    var result3: i64 = 0;
    for(testCases3.items) |testCaseInput| {
        const result = calculateEnergy(128, &plantMap3, parent3, testCaseInput);
        if(result != 0) {
            result3 += maxResult - result;
        }
    }

    return [3]i64{result1,result2,result3};
}

// This only works because this specific puzzle input is set up so that
// each input plant is always positive weighted or always negative weighted.
// We just set negative weighted inputs to 0
fn getMaxInput(plantMap: *const std.AutoHashMap(u16, *Plant)) std.StaticBitSet(128) {
    var maxInput = std.StaticBitSet(128).empty;
    var maxInputPlantId: u16 = 0;
    var it = plantMap.keyIterator();
    while(it.next()) |key| {
        const plant = plantMap.get(key.*).?;
        for(plant.incomingBranches.items) |branch| {
            if(branch.incomingPlant == null and plant.id > maxInputPlantId) {
                maxInputPlantId = plant.id;
            }
        }
    }
    it = plantMap.keyIterator();
    while(it.next()) |key| {
        const plant = plantMap.get(key.*).?;
        for(plant.incomingBranches.items) |branch| {
            if(branch.thickness > 0 and branch.incomingPlant != null and branch.incomingPlant.? <= maxInputPlantId) {
                maxInput.set(branch.incomingPlant.? - 1);
            }
        }
    }
    return maxInput;
}

fn calculateEnergy(comptime SIZE: comptime_int, plantMap: *const std.AutoHashMap(u16, *Plant), plant: *Plant, inputs: std.StaticBitSet(SIZE)) i64 {
    var energy: i64 = 0;
    for(plant.incomingBranches.items) |branch| {
        if(branch.incomingPlant) |incomingId| {
            const incomingPlant = plantMap.get(incomingId).?;
            const incomingPlantEnergy = calculateEnergy(SIZE, plantMap, incomingPlant, inputs);
            energy += incomingPlantEnergy * branch.thickness;
        } else {
            energy += if(inputs.isSet(branch.outgoingPlant - 1)) branch.thickness else 0;
        }
    }
    return if(energy >= plant.thickness) energy else 0;
}

fn findParent(plantMap: *const std.AutoHashMap(u16, *Plant)) !*Plant {
    var it = plantMap.keyIterator();
    while(it.next()) |key| {
        const plant = plantMap.get(key.*).?;
        if(plant.outgoingBranches.items.len == 0) {
            return plant;
        }
    }
    return error.notFound;
}

fn createPlantMap(comptime BITSET_SIZE: comptime_int, allocator: Allocator, reader: *Reader) !struct{std.AutoHashMap(u16, *Plant), std.ArrayList(std.StaticBitSet(BITSET_SIZE))} {
    var currentPlantId: u16 = 0;
    var plantMap = std.AutoHashMap(u16, *Plant).init(allocator);
    var testCases = std.ArrayList(std.StaticBitSet(BITSET_SIZE)).empty;
    while(readLine(reader)) |line| {
        if(line.len == 0) {
            continue;
        }
        if(line.len == 3 and line[0] == '~') {
            break;
        }
        if(line[0] == 'P') {
            var it = std.mem.tokenizeAny(u8, line, " :");
            _ = it.next();
            currentPlantId = try std.fmt.parseInt(u16, it.next().?, 10);
            _ = it.next();
            _ = it.next();
            const thickness = try std.fmt.parseInt(u32, it.next().?, 10);
            const list1 = try allocator.create(std.ArrayList(Branch));
            list1.* = std.ArrayList(Branch).empty;
            const list2 = try allocator.create(std.ArrayList(Branch));
            list2.* = std.ArrayList(Branch).empty;
            const plant = try allocator.create(Plant);
            plant.* = .{.id = currentPlantId, .thickness = thickness, .incomingBranches = list1, .outgoingBranches = list2};
            try plantMap.put(currentPlantId, plant);
        } else if (line[2] == 'f') {
            const plant = plantMap.get(currentPlantId).?;
            const thickness = try std.fmt.parseInt(i32, line[29..], 10);
            try plant.incomingBranches.append(allocator, .{.thickness = thickness, .outgoingPlant = currentPlantId});
        } else if (line[2] == 'b') {
            const plant = plantMap.get(currentPlantId).?;
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = it.next();
            _ = it.next();
            _ = it.next();
            _ = it.next();
            const incomingPlantId = try std.fmt.parseInt(u16, it.next().?, 10);
            const incomingPlant = plantMap.get(incomingPlantId).?;
            _ = it.next();
            _ = it.next();
            const thickness = try std.fmt.parseInt(i32, it.next().?, 10);
            const branch: Branch = .{.thickness = thickness, .incomingPlant = incomingPlantId, .outgoingPlant = currentPlantId};
            try plant.incomingBranches.append(allocator, branch);
            try incomingPlant.outgoingBranches.append(allocator, branch);
        } else if (line[0] == '0' or line[0] == '1') {
            var it = std.mem.tokenizeScalar(u8, line, ' ');
            var bitset = std.StaticBitSet(BITSET_SIZE).empty;
            var bitNum: usize = 0;
            while(it.next()) |bit| {
                if(bit[0] == '1') {
                    bitset.set(bitNum);
                }
                bitNum += 1;
            }
            try testCases.append(allocator, bitset);
        }
    }
    return .{plantMap, testCases};
}

fn nextStateFn(context: AStarContext, state: AStarState, allocator: Allocator) std.ArrayList(AStarState) {
    //std.debug.print("{}\n", .{state.coord});
    var list = std.ArrayList(AStarState).empty;
    const coord = state.coord;
    const leftOptional = if (coord.x > 0) UCoord{ .x = coord.x - 1, .y = coord.y } else null;
    const upOptional = if (coord.y > 0) UCoord{ .x = coord.x, .y = coord.y - 1 } else null;
    const rightOptional = if (coord.x < context.dim - 1) UCoord{ .x = coord.x + 1, .y = coord.y } else null;
    const downOptional = if (coord.y < context.dim - 1) UCoord{ .x = coord.x, .y = coord.y + 1 } else null;
    if (leftOptional) |left| {
        if (!withinRadius(left.x, left.y, context.volcano, context.radius)) {
            const newState = createState(left, context.volcano, state);
            list.append(allocator, newState) catch unreachable;
        }
    }
    if (rightOptional) |right| {
        if (!withinRadius(right.x, right.y, context.volcano, context.radius)) {
            const newState = createState(right, context.volcano, state);
            list.append(allocator, newState) catch unreachable;
        }
    }
    if (upOptional) |up| {
        if (!withinRadius(up.x, up.y, context.volcano, context.radius)) {
            const newState = createState(up, context.volcano, state);
            list.append(allocator, newState) catch unreachable;
        }
    }
    if (downOptional) |down| {
        if (!withinRadius(down.x, down.y, context.volcano, context.radius)) {
            const newState = createState(down, context.volcano, state);
            list.append(allocator, newState) catch unreachable;
        }
    }
    return list;
}

fn transitionCostFn(context: AStarContext, _: AStarState, b: AStarState) u32 {
    return context.grid[b.coord.x][b.coord.y];
}

fn estimateFn(context: AStarContext, state: AStarState) u32 {
    if (!state.checkpoint1) {
        return checkpoint1Estimate(context, state.coord);
    } else if (!state.checkpoint2) {
        return checkpoint2Estimate(context, state.coord);
    } else if (!state.checkpoint3) {
        return checkpoint3Estimate(context, state.coord);
    } else {
        return toStartEstimate(context, state.coord);
    }
}

fn isSolutionFn(context: AStarContext, state: AStarState) bool {
    return state.checkpoint1 and state.checkpoint2 and state.checkpoint3 and state.coord.x == context.start.x and state.coord.y == context.start.y;
}

// Distance to line extending left from volcano, plus distance to checkpoint2, checkpoint3, and start
fn checkpoint1Estimate(context: AStarContext, coord: UCoord) u32 {
    const checkpoint1 = UCoord{ .x = context.volcano.x - context.radius - 1, .y = context.volcano.y };
    const distToCheckpoint1X = if (coord.x > checkpoint1.x) coord.x - checkpoint1.x else 0;
    const distToCheckpoint1Y = @max(checkpoint1.y, coord.y) - @min(checkpoint1.y, coord.y);
    const distToCheckpoint1: u32 = @intCast(distToCheckpoint1X + distToCheckpoint1Y);
    return distToCheckpoint1 + checkpoint2Estimate(context, checkpoint1);
}

// Distance to line extending down from volcano, plus distance to checkpoint3 and start
fn checkpoint2Estimate(context: AStarContext, coord: UCoord) u32 {
    const checkpoint2 = UCoord{ .x = context.volcano.x, .y = context.volcano.y + context.radius + 1 };
    const distToCheckpoint2Y = if (coord.y < checkpoint2.y) checkpoint2.y - coord.y else 0;
    const distToCheckpoint2X = @max(checkpoint2.x, coord.x) - @min(checkpoint2.x, coord.x);
    const distToCheckpoint2: u32 = @intCast(distToCheckpoint2Y + distToCheckpoint2X);
    return distToCheckpoint2 + checkpoint3Estimate(context, checkpoint2);
}

// Distance to line extending right of volcano, plus distance to start
fn checkpoint3Estimate(context: AStarContext, coord: UCoord) u32 {
    const checkpoint3 = UCoord{ .x = context.volcano.x + context.radius + 1, .y = context.volcano.y };
    const distToCheckpoint3X = if (coord.x < checkpoint3.x) checkpoint3.x - coord.x else 0;
    const distToCheckpoint3Y = @max(checkpoint3.y, coord.y) - @min(checkpoint3.y, coord.y);
    const distToCheckpoint3: u32 = @intCast(distToCheckpoint3X + distToCheckpoint3Y);
    return distToCheckpoint3 + toStartEstimate(context, checkpoint3);
}

fn toStartEstimate(context: AStarContext, coord: UCoord) u32 {
    const estimate = @max(context.start.x, coord.x) - @min(context.start.x, coord.x) + @max(context.start.y, coord.y) + @min(context.start.y, coord.y);
    return @intCast(estimate);
}

fn createState(coord: UCoord, volcano: UCoord, previousState: AStarState) AStarState {
    const checkpoint1 = previousState.checkpoint1 or (coord.y == volcano.y and coord.x < volcano.x);
    const checkpoint2 = previousState.checkpoint2 or (coord.x == volcano.x and coord.y > volcano.y);
    const checkpoint3 = previousState.checkpoint3 or (coord.y == volcano.y and coord.x > volcano.x);
    return .{ .coord = coord, .checkpoint1 = checkpoint1, .checkpoint2 = checkpoint2, .checkpoint3 = checkpoint3 };
}

fn parseGrid(comptime DIM: usize, reader: *Reader) struct { [DIM][DIM]u8, UCoord, UCoord } {
    var grid: [DIM][DIM]u8 = @splat(@splat(0));
    var lineNum: usize = 0;
    var volcanoStart: UCoord = .{ .x = 0, .y = 0 };
    var loopStart: UCoord = .{ .x = 0, .y = 0 };
    while (readLine(reader)) |line| {
        if (line.len == 0) {
            break;
        }
        for (line, 0..) |char, x| {
            if (char == '@') {
                volcanoStart = .{ .x = x, .y = lineNum };
                grid[x][lineNum] = 0;
            } else if (char == 'S') {
                loopStart = .{ .x = x, .y = lineNum };
                grid[x][lineNum] = 0;
            } else {
                grid[x][lineNum] = char - '0';
            }
        }
        lineNum += 1;
    }
    return .{ grid, volcanoStart, loopStart };
}

fn calculateDestruction(comptime DIM: usize, grid: *const [DIM][DIM]u8, volcano: UCoord, radius: usize) u64 {
    var result: u64 = 0;
    for (0..DIM) |y| {
        for (0..DIM) |x| {
            if (withinRadius(x, y, volcano, radius)) {
                result += grid[x][y];
            }
        }
    }
    return result;
}

fn withinRadius(x: usize, y: usize, volcano: UCoord, radius: usize) bool {
    const xDist = @max(volcano.x, x) - @min(volcano.x, x);
    const yDist = @max(volcano.y, y) - @min(volcano.y, y);
    return xDist * xDist + yDist * yDist <= radius * radius;
}

fn parseNumberList(allocator: Allocator, reader: *Reader) !std.ArrayList(u32) {
    var list = std.ArrayList(u32).empty;
    const line = readLine(reader).?;
    var it = std.mem.tokenizeScalar(u8, line, ',');
    while (it.next()) |next| {
        try list.append(allocator, try std.fmt.parseInt(u32, next, 10));
    }
    return list;
}

const UCoord = struct {
    x: usize,
    y: usize,
};

const AStarState = struct {
    coord: UCoord,
    checkpoint1: bool = false,
    checkpoint2: bool = false,
    checkpoint3: bool = false,
};

const AStarContext = struct {
    grid: *const [DIM3][DIM3]u8,
    start: UCoord,
    volcano: UCoord,
    radius: usize,
    dim: usize,
};

const Plant = struct {
    id: u16,
    thickness: u32,
    incomingBranches: *std.ArrayList(Branch),
    outgoingBranches: *std.ArrayList(Branch),
};

const Branch = struct {
    thickness: i32,
    outgoingPlant: u16,
    incomingPlant: ?u16 = null,
};
