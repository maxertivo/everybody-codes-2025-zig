const std = @import("std");
const part1 = @import("day1to5.zig");
// const part2 = @import("day7to12.zig");
// const part3 = @import("day13to18.zig");
// const part4 = @import("day19to25.zig");
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const startTime = std.time.milliTimestamp();

    const result1p1 = try part1.day1p1(allocator);
    const result1p2 = try part1.day1p2(allocator);
    const result1p3 = try part1.day1p3(allocator);

    println("Day 1: {{ {s}, {s}, {s} }}", .{result1p1, result1p2, result1p3});

    // const result2 = try part1.day2();
    // println("Day 2: {{ {s}, {s}, {s} }}", .{result2[0], result2[1], result2[2]});

    const result3 = try part1.day3(allocator);
    println("Day 3: {any}", .{result3});

    const result4 = try part1.day4(allocator);
    println("Day 4: {any}", .{result4});

    const result5 = try part1.day5(allocator);
    println("Day 5: {any}", .{result5});

    // const result6 = try part1.day6(allocator);
    // println("Day 6: {any}", .{result6});

    // const result7 = try part2.day7(allocator);
    // println("Day 7: {{ {s}, {s} }}", .{result7[0], result7[1]});

    // const result8 = try part2.day8(allocator);
    // println("Day 8: {any}", .{result8});

    // const result9 = try part2.day9(allocator);
    // println("Day 9: {any}", .{result9});

    // const result10 = try part2.day10(allocator);
    // println("Day 10: {any}", .{result10});

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

    // const result21 = try part4.day21(allocator);
    // println("Day 21: {any}", .{result21});

    // const result22 = try part4.day22(allocator);
    // println("Day 22: {any}", .{result22});

    // const result23 = try part4.day23(allocator);
    // println("Day 23: {any}", .{result23});

    // const result24 = try part4.day24(allocator);
    // println("Day 24: {any}", .{result24});

    // const result25 = try part4.day25(allocator);
    // println("Day 25: {any}", .{result25});

    const endTime = std.time.milliTimestamp();
    println("Elapsed time in ms: {d}", .{endTime - startTime});
}

fn println(comptime string: []const u8, args: anytype) void {
    var stdout_writer = std.fs.File.stdout().writer(utils.GLOBAL_STDOUT_BUFFER);
    const stdout = &stdout_writer.interface;

    stdout.print(string, args) catch return;
    stdout.print("\n", .{}) catch return;
    stdout.flush() catch return;
}