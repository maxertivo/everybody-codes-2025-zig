const std = @import("std");
const utils = @import("utils.zig");

const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;
const fs = std.fs;

const readLine = utils.readLine;

pub fn day16(allocator: Allocator, reader: *Reader) ![3]u64 {
    // Part 1
    var list = try parseNumberList(allocator, reader);
    var result1: u64 = 0;
    for(list.items) |item| {
        result1 += 90 / item;
    }

    // Part2
    _ = readLine(reader);
    list = try parseNumberList(allocator, reader);
    var spell = std.ArrayList(u32).empty;
    var result2: u64 = 1;
    for(list.items, 1..) |item, i| {
        const index: u32 = @intCast(i);
        if(spell.items.len == 0) {
            try spell.append(allocator, index);
        } else {
            var factors: u32 = 0;
            for(spell.items) |factor| {
                if(index % factor == 0) {
                    factors += 1;
                }
            }
            if(factors < item) {
                try spell.append(allocator, index);
            }
        }
    }
    for(spell.items) |item| {
        result2 *= item;
    }

    // Part3
    _ = readLine(reader);
    list = try parseNumberList(allocator, reader);
    spell = std.ArrayList(u32).empty;
    for(list.items, 1..) |item, i| {
        const index: u32 = @intCast(i);
        if(spell.items.len == 0) {
            try spell.append(allocator, index);
        } else {
            var factors: u32 = 0;
            for(spell.items) |factor| {
                if(index % factor == 0) {
                    factors += 1;
                }
            }
            if(factors < item) {
                try spell.append(allocator, index);
            }
        }
    }
    var lengthFactor: f64 = 0;
    for(spell.items) |item| {
        lengthFactor += 1 / @as(f64, item);
    }
    const totalBricks = 202520252025000;

    // This should be very close to the final answer
    var result3: u64 = @ceil(@as(f64, totalBricks) / lengthFactor);

    while(true) {
        var bricks: u64 = 0;
        for(spell.items) |item| {
            bricks += result3 / item;
        }
        if(bricks < totalBricks) {
            result3 += 1;
        } else {
            if(bricks > totalBricks) {
                result3 -= 1;
            }
            break;
        }
    }

    return [3]u64{result1, result2, result3};
}

fn parseNumberList(allocator: Allocator, reader: *Reader) !std.ArrayList(u32) {
    var list = std.ArrayList(u32).empty;
    const line = readLine(reader).?;
    var it = std.mem.tokenizeScalar(u8, line, ',');
    while(it.next()) |next| {
        try list.append(allocator, try std.fmt.parseInt(u32, next, 10));
    }
    return list;
}
