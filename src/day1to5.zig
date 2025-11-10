const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day1p1(a: Allocator) ![20]u8 {
    var arena = std.heap.ArenaAllocator.init(a);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file: fs.File = try fs.cwd().openFile("src/inputs/day1-1.txt",.{},);
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);

    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(&reader.interface) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.interface.discardDelimiterInclusive('\n');
    const line2 = readLine(&reader.interface) orelse return error.invalid;
    it = std.mem.tokenizeScalar(u8, line2, ',');
    while(it.next()) |next| {
        const amount = try std.fmt.parseInt(u32, next[1..], 10);
        try instructions.append(allocator, .{.goRight = next[0] == 'R', .amount = amount});
    }

    var part1: [20]u8 = @splat(0);

    var index: i64 = 0;
    for(instructions.items) |item| {
        if(item.goRight) {
            index += item.amount; 
            if(index >= stringList.items.len) {
                index = @as(i64, @intCast(stringList.items.len - 1));
            }
        } else {
            if(item.amount >= index) {
                index = 0;
            } else {
                index -= item.amount;
            }
        }
    }

    std.mem.copyForwards(u8, &part1, stringList.items[@abs(index)]);

    index = 0;
    for(instructions.items) |item| {
        if(item.goRight) {
            index += item.amount; 
            while(index >= stringList.items.len) {
                index -= @as(i64, @intCast(stringList.items.len));
            }
        } else {
            index -= item.amount;
            while(index < 0) {
                index += @as(i64, @intCast(stringList.items.len));
            }
        }
    }

    std.mem.copyForwards(u8, &part1, stringList.items[@abs(index)]);

    return part1;
}

pub fn day1p2(a: Allocator) ![20]u8 {
    var arena = std.heap.ArenaAllocator.init(a);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file: fs.File = try fs.cwd().openFile("src/inputs/day1-2.txt",.{},);
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);

    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(&reader.interface) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.interface.discardDelimiterInclusive('\n');
    const line2 = readLine(&reader.interface) orelse return error.invalid;
    it = std.mem.tokenizeScalar(u8, line2, ',');
    while(it.next()) |next| {
        const amount = try std.fmt.parseInt(u32, next[1..], 10);
        try instructions.append(allocator, .{.goRight = next[0] == 'R', .amount = amount});
    }

    var part2: [20]u8 = @splat(0);

    var index: i64 = 0;
    for(instructions.items) |item| {
        if(item.goRight) {
            index += item.amount; 
            while(index >= stringList.items.len) {
                index -= @as(i64, @intCast(stringList.items.len));
            }
        } else {
            index -= item.amount;
            while(index < 0) {
                index += @as(i64, @intCast(stringList.items.len));
            }
        }
    }

    std.mem.copyForwards(u8, &part2, stringList.items[@abs(index)]);

    return part2;
}

pub fn day1p3(a: Allocator) ![20]u8 {
    var arena = std.heap.ArenaAllocator.init(a);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file: fs.File = try fs.cwd().openFile("src/inputs/day1-3.txt",.{},);
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);

    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(&reader.interface) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.interface.discardDelimiterInclusive('\n');
    const line2 = readLine(&reader.interface) orelse return error.invalid;
    it = std.mem.tokenizeScalar(u8, line2, ',');
    while(it.next()) |next| {
        const amount = try std.fmt.parseInt(u32, next[1..], 10);
        try instructions.append(allocator, .{.goRight = next[0] == 'R', .amount = amount});
    }

    var part3: [20]u8 = @splat(0);

    var index: i64 = 0;
    for(instructions.items) |item| {
        if(item.goRight) {
            index += item.amount; 
            while(index >= stringList.items.len) {
                index -= @as(i64, @intCast(stringList.items.len));
            }
        } else {
            index -= item.amount;
            while(index < 0) {
                index += @as(i64, @intCast(stringList.items.len));
            }
        }
        const temp = stringList.items[0];
        stringList.items[0] = stringList.items[@abs(index)];
        stringList.items[@abs(index)] = temp;
    }

    std.mem.copyForwards(u8, &part3, stringList.items[0]);

    return part3;
}

pub fn day2() ![3][20]u8 {
    const file: fs.File = try fs.cwd().openFile("src/inputs/day2.txt",.{},);
    defer file.close();

    var reader = file.reader(utils.GLOBAL_FILE_BUFFER);
    const line1 = readLine(&reader.interface) orelse return error.invalid;
    var it = std.mem.tokenizeAny(u8, line1, "A=[],");
    var a = try std.fmt.parseInt(i64, it.next().?, 10);
    var b = try std.fmt.parseInt(i64, it.next().?, 10);
    const complex1 = Complex{.a = a, .b = b};
    const line2 = readLine(&reader.interface) orelse return error.invalid;
    it = std.mem.tokenizeAny(u8, line2, "A=[],");
    a = try std.fmt.parseInt(i64, it.next().?, 10);
    b = try std.fmt.parseInt(i64, it.next().?, 10);
    const complex2 = Complex{.a = a, .b = b};
    const line3 = readLine(&reader.interface) orelse return error.invalid;
    it = std.mem.tokenizeAny(u8, line3, "A=[],");
    a = try std.fmt.parseInt(i64, it.next().?, 10);
    b = try std.fmt.parseInt(i64, it.next().?, 10);
    const complex3 = Complex{.a = a, .b = b};

    var result1 = Complex{.a = 0, .b = 0};
    for(0..3) |_| {
        result1 = mul(result1, result1);
        result1 = div(result1, Complex{.a = 10, .b = 10});
        result1 = add(result1, complex1);
    }

    var buf1: [20]u8 = @splat(0);
    _ = try std.fmt.bufPrint(&buf1, "[{d},{d}]", .{result1.a, result1.b});

    var part2: u32 = 0;
    for(0..101) |i| {
        for(0..101) |j| {
            var result2 = Complex{.a = 0, .b = 0};
            for(0..100) |_| {
                result2 = mul(result2, result2);
                result2 = div(result2, Complex{.a = 100000, .b = 100000});
                result2 = add(result2, add(complex2, Complex{.a = @intCast(10*i), .b = @intCast(10*j)}));
                if(@abs(result2.a) > 1000000 or @abs(result2.b) > 10000000) {
                    break;
                }
            }
            if(@abs(result2.a) <= 1000000 and @abs(result2.b) <= 1000000) {
                part2 += 1;
            }
        }
    }

    var buf2: [20]u8 = @splat(0);
    _ = try std.fmt.bufPrint(&buf2, "{d}", .{part2});

    var part3: u32 = 0;
    for(0..1001) |i| {
        for(0..1001) |j| {
            var result3 = Complex{.a = 0, .b = 0};
            for(0..100) |_| {
                result3 = mul(result3, result3);
                result3 = div(result3, Complex{.a = 100000, .b = 100000});
                result3 = add(result3, add(complex3, Complex{.a = @intCast(i), .b = @intCast(j)}));
                if(@abs(result3.a) > 1000000 or @abs(result3.b) > 10000000) {
                    break;
                }
            }
            if(@abs(result3.a) <= 1000000 and @abs(result3.b) <= 1000000) {
                part3 += 1;
            }
        }
    }

    var buf3: [20]u8 = @splat(0);
    _ = try std.fmt.bufPrint(&buf3, "{d}", .{part3});

    return [3][20]u8{buf1, buf2, buf3};
}

fn add(c1: Complex, c2: Complex) Complex {
    return Complex{.a = c1.a + c2.a, .b = c1.b + c2.b};
}

fn mul(c1: Complex, c2: Complex) Complex {
    return Complex{.a = c1.a * c2.a - c1.b * c2.b, .b = c1.a * c2.b + c1.b * c2.a};
}

fn div(c1: Complex, c2: Complex) Complex {
    return Complex{.a = @divTrunc(c1.a, c2.a), .b = @divTrunc(c1.b, c2.b)};
}

const Instruction = struct {
    goRight: bool,
    amount: u32,
};

const Complex = struct {
    a: i64,
    b: i64,
};