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
