const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day1p1(allocator: Allocator, reader: *Reader) ![20]u8 {
    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(reader) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.discardDelimiterInclusive('\n');
    const line2 = readLine(reader) orelse return error.invalid;
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

pub fn day1p2(allocator: Allocator, reader: *Reader) ![20]u8 {
    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(reader) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.discardDelimiterInclusive('\n');
    const line2 = readLine(reader) orelse return error.invalid;
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

pub fn day1p3(allocator: Allocator, reader: *Reader) ![20]u8 {
    var stringList = std.ArrayList([]u8).empty;
    var instructions = std.ArrayList(Instruction).empty;

    const line1 = readLine(reader) orelse return error.invalid;
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const dupe = try allocator.dupe(u8, next);
        try stringList.append(allocator, dupe);
    }
    _ = try reader.discardDelimiterInclusive('\n');
    const line2 = readLine(reader) orelse return error.invalid;
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

pub fn day2(_: Allocator, reader: *Reader) ![3][20]u8 {
    const line1 = readLine(reader) orelse return error.invalid;
    var it = std.mem.tokenizeAny(u8, line1, "A=[],");
    var a = try std.fmt.parseInt(i64, it.next().?, 10);
    var b = try std.fmt.parseInt(i64, it.next().?, 10);
    const complex1 = Complex{.a = a, .b = b};
    const line2 = readLine(reader) orelse return error.invalid;
    it = std.mem.tokenizeAny(u8, line2, "A=[],");
    a = try std.fmt.parseInt(i64, it.next().?, 10);
    b = try std.fmt.parseInt(i64, it.next().?, 10);
    const complex2 = Complex{.a = a, .b = b};
    const line3 = readLine(reader) orelse return error.invalid;
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

pub fn day3(allocator: Allocator, reader: *Reader) ![3]u32 {
    const line1 = readLine(reader) orelse return error.invalid;

    var set = std.AutoHashMap(u32, void).init(allocator);
    var it = std.mem.tokenizeScalar(u8, line1, ',');
    while(it.next()) |next| {
        const num = try std.fmt.parseInt(u32, next, 10);
        try set.put(num, void{});
    }

    var part1: u32 = 0;
    var iter = set.keyIterator();
    while(iter.next()) |key_ptr| {
        part1 += key_ptr.*;
    }

    const line2 = readLine(reader) orelse return error.invalid;
    var list = std.ArrayList(u32).empty;
    it = std.mem.tokenizeScalar(u8, line2, ',');
    while(it.next()) |next| {
        const num = try std.fmt.parseInt(u32, next, 10);
        try list.append(allocator, num);
    }
    std.mem.sort(u32, list.items, void{}, std.sort.asc(u32));
    var prev: u32 = 99999999;
    var count: u32 = 0;
    var part2: u32 = 0;
    for(list.items) |item| {
        if(count >= 20) {
            break;
        }
        if(item != prev) {
            prev = item;
            count += 1;
            part2 += item;
        }
    }

    const line3 = readLine(reader) orelse return error.invalid;
    list.clearRetainingCapacity();
    it = std.mem.tokenizeScalar(u8, line3, ',');
    while(it.next()) |next| {
        const num = try std.fmt.parseInt(u32, next, 10);
        try list.append(allocator, num);
    }
    const max = std.sort.max(u32, list.items, void{}, std.sort.asc(u32)).?;
    var array = try allocator.alloc(u16, max + 1);
    @memset(array, 0);
    for(list.items) |item| {
        array[item] += 1;
    }
    const part3 = std.sort.max(u16, array, void{}, std.sort.asc(u16)).?;

    return [3]u32{part1,part2,part3};
}

pub fn day4(allocator: Allocator, reader: *Reader) ![3]u128 {
    var list = std.ArrayList(u32).empty;
    while(true) {
        const line = readLine(reader) orelse break;
        if(line.len == 0) {
            break;
        }
        try list.append(allocator, try std.fmt.parseInt(u32, line, 10));
    }

    const part1 = @divTrunc(list.items[0] * 2025, list.items[list.items.len - 1]);

    list.clearRetainingCapacity();
    while(true) {
        const line = readLine(reader) orelse break;
        if(line.len == 0) {
            break;
        }
        try list.append(allocator, try std.fmt.parseInt(u32, line, 10));
    }

    const part2 = try std.math.divCeil(u128, @as(u128, @intCast(list.items[list.items.len - 1])) * 10000000000000, list.items[0]);

    list.clearRetainingCapacity();
    var factor:u32 = 1;
    while(true) {
        const line = readLine(reader) orelse break;
        if(line.len == 0) {
            break;
        }
        if(line.len < 5) {
            try list.append(allocator, try std.fmt.parseInt(u32, line, 10));
        } else {
            var it = std.mem.tokenizeScalar(u8, line, '|');
            const a1 = try std.fmt.parseInt(u32, it.next().?, 10);
            const b1 = try std.fmt.parseInt(u32, it.next().?, 10);
            factor *= @divExact(b1, a1);
        }
    }

    const part3 = @divTrunc(@as(u128, @intCast(list.items[0])) * 100 * factor, list.items[1]);

    return [3]u128{part1,part2,part3};
}

pub fn day5(allocator: Allocator, reader: *Reader) ![3]u64 {
    const line1 = readLine(reader) orelse return error.invalid;

    const sword1 = try getSword(line1, allocator);
    const qual1 = sword1.quality;

    _ = readLine(reader);
    var max: u64 = 0;
    var min: u64 = std.math.maxInt(u64);
    while(true) {
        const line = readLine(reader) orelse break;
        if(line.len == 0) {
            break;
        }
        const sword2 = try getSword(line, allocator);
        const qual = sword2.quality;
        if(qual < min) {
            min = qual;
        }
        if(qual > max) {
            max = qual;
        }
    }

    var swords = std.ArrayList(*Sword).empty;
    while(true) {
        const line = readLine(reader) orelse break;
        const sword3 = try getSword(line, allocator);
        try swords.append(allocator, sword3);
    }
    std.mem.sort(*Sword, swords.items, void{}, swordLessThan);
    std.mem.reverse(*Sword, swords.items);

    var part3: u64 = 0;
    for(1..swords.items.len+1) |index| {
        part3 += index * swords.items[index-1].id;
    }

    return [3]u64{qual1,max - min,part3};
}

fn swordLessThan(context: void, s1: *Sword, s2: *Sword) bool {
    _ = context;
    if(s1.quality < s2.quality) {
        return true;
    } else if (s1.quality > s2.quality) {
        return false;
    }
    for(0..s1.list.items.len) |i| {
        const el1 = s1.list.items[i];
        const el2 = s2.list.items[i];
        var buf: [6]u8 = @splat(0);
        var index: usize = 0;
        if(el1.left) |left| {
            index += std.fmt.printInt(buf[index..], left, 10, .lower, .{});
        }
        index += std.fmt.printInt(buf[index..], el1.center, 10, .lower, .{});
        if(el1.right) |right| {
            index += std.fmt.printInt(buf[index..], right, 10, .lower, .{});
        }
        const comp1 = std.fmt.parseInt(u32, buf[0..index], 10) catch 0;

        buf = @splat(0);
        index = 0;
        if(el2.left) |left| {
            index += std.fmt.printInt(buf[index..], left, 10, .lower, .{});
        }
        index += std.fmt.printInt(buf[index..], el2.center, 10, .lower, .{});
        if(el2.right) |right| {
            index += std.fmt.printInt(buf[index..], right, 10, .lower, .{});
        }
        const comp2 = std.fmt.parseInt(u32, buf[0..index], 10) catch 0;
        if(comp1 < comp2) {
            return true;
        } else if (comp2 < comp1) {
            return false;
        }
    }
    return s1.id < s2.id;
}

fn getSword(line: []const u8, allocator: Allocator) !*Sword {
    const sword = try allocator.create(Sword);
    const list = try allocator.create(std.ArrayList(*Spine));
    list.* = .empty;
    var it = std.mem.tokenizeAny(u8, line, ":,");
    const id = try std.fmt.parseInt(u32, it.next().?, 10);
    while(it.next()) |next| {
        const val = try std.fmt.parseInt(u32, next, 10);
        var placed = false;
        for(list.items) |segment| {
            if(val < segment.center and segment.left == null) {
                segment.left = val;
                placed = true;
                break;
            } else if (val > segment.center and segment.right == null) {
                segment.right = val;
                placed = true;
                break;
            }
        }
        if(!placed) {
            const spine = try allocator.create(Spine);
            spine.* = .{.center = val};
            try list.append(allocator, spine);
        }
    }

    var buf: [20]u8 = @splat(0);
    var index: usize = 0;
    for(list.items) |item| {
        index += std.fmt.printInt(buf[index..], item.center, 10, .lower, .{});
    }
    const qual = try std.fmt.parseInt(u64, buf[0..index], 10);
    sword.* = .{.id = id, .list = list, .quality = qual};
    return sword;
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

const Spine = struct {
    center: u32,
    left: ?u32 = null,
    right: ?u32 = null,
};

const Sword = struct {
    id: u32,
    list: *std.ArrayList(*Spine),
    quality: u64,
};
