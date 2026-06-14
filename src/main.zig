const std = @import("std");
const part1 = @import("day1to5.zig");
const part2 = @import("day6to10.zig");
// const part3 = @import("day13to18.zig");
// const part4 = @import("day19to25.zig");
const utils = @import("utils.zig");
const Reader = std.Io.Reader;
const ArenaAllocator = std.heap.ArenaAllocator;
const Allocator = std.mem.Allocator;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena;
    const startTime = std.Io.Timestamp.now(io, .real);

    const result1p1 = try solveDay([20]u8, "src/inputs/day1-1.txt", io, allocator, part1.day1p1);
    const result1p2 = try solveDay([20]u8, "src/inputs/day1-2.txt", io, allocator, part1.day1p2);
    const result1p3 = try solveDay([20]u8, "src/inputs/day1-3.txt", io, allocator, part1.day1p3);

    println(io, "Day 1: {{ {s}, {s}, {s} }}", .{ result1p1, result1p2, result1p3 });

    // const result2 = try solveDay([3][20]u8, "src/inputs/day2.txt", io, allocator, part1.day2);
    // println(io, "Day 2: {{ {s}, {s}, {s} }}", .{result2[0], result2[1], result2[2]});

    const result3 = try solveDay([3]u32, "src/inputs/day3.txt", io, allocator, part1.day3);
    println(io, "Day 3: {any}", .{result3});

    const result4 = try solveDay([3]u128, "src/inputs/day4.txt", io, allocator, part1.day4);
    println(io, "Day 4: {any}", .{result4});

    const result5 = try solveDay([3]u64, "src/inputs/day5.txt", io, allocator, part1.day5);
    println(io, "Day 5: {any}", .{result5});

    const result6 = try solveDay([3]u64, "src/inputs/day6.txt", io, allocator, part2.day6);
    println(io, "Day 6: {any}", .{result6});

    const result7: [3][20]u8 = try solveDay([3][20]u8, "src/inputs/day7.txt", io, allocator, part2.day7);
    println(io, "Day 7: {{ {s}, {s}, {s} }}", .{ result7[0], result7[1], result7[2] });

    const result8 = try solveDay([3]u32, "src/inputs/day8.txt", io, allocator, part2.day8);
    println(io, "Day 8: {any}", .{result8});

    const result9 = try solveDay([3]u32, "src/inputs/day9.txt", io, allocator, part2.day9);
    println(io, "Day 9: {any}", .{result9});

    const result10 = try solveDay([3]u64, "src/inputs/day10.txt", io, allocator, part2.day10);
    println(io, "Day 10: {any}", .{result10});

    // const result11 = try part2.day11(allocator);
    // println("Day 11: {{ {{{d},{d}}}, {{{d},{d},{d}}} }}", .{result11[0], result11[1], result11[2], result11[3], result11[4]});

    // const result12 = try part2.day12(allocator);
    // println("Day 12: {any}", .{result12});

    // const result13 = try part3.day13(allocator);
    // println("Day 13: {{ {{{d},{d}}}, {{{d},{d}}} }}", .{result13[0], result13[1], result13[2], result13[3]});

    // const result14 = try part3.day14(allocator);
    // println("Day 14: {{ {s}, {s} }}", .{result14[0], result14[1]});

    // const result15 = try part3.day15(allocator);
    // println("Day 15: {any}", .{result15});

    // const result16 = try part3.day16(allocator);
    // println("Day 16: {any}", .{result16});

    // const result17 = try part3.day17();
    // println("Day 17: {any}", .{result17});

    // const result18 = try part3.day18(allocator);
    // println("Day 18: {any}", .{result18});

    // const result19 = try part4.day19(allocator);
    // println("Day 19: {any}", .{result19});

    // const result20 = try part4.day20(allocator);
    // println("Day 20: {any}", .{result20});

    const endTime = std.Io.Timestamp.now(io, .real);
    println(io, "Elapsed time in ms: {d}", .{endTime.toMilliseconds() - startTime.toMilliseconds()});
}

// Prepares the allocator and file reader for each solution function
fn solveDay(comptime Result: type, comptime path: []const u8, io: std.Io, arena: *ArenaAllocator, comptime solverFn: fn (allocator: Allocator, reader: *Reader) anyerror!Result) anyerror!Result {
    const allocator = arena.allocator();
    defer _ = arena.reset(.free_all);

    const file: std.Io.File = try std.Io.Dir.cwd().openFile(
        io,
        path,
        .{},
    );
    defer file.close(io);

    var reader = file.reader(io, utils.GLOBAL_FILE_BUFFER);
    return try solverFn(allocator, &reader.interface);
}

fn SolverReturnType(comptime solverFn: anytype) type {
    return @typeInfo(@TypeOf(solverFn)).@"fn".return_type.?;
}

fn println(io: std.Io, comptime string: []const u8, args: anytype) void {
    var stdout_writer = std.Io.File.stdout().writer(io, utils.GLOBAL_STDOUT_BUFFER);
    const stdout = &stdout_writer.interface;

    stdout.print(string, args) catch return;
    stdout.print("\n", .{}) catch return;
    stdout.flush() catch return;
}
