const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.Io.Reader;

var GLOBAL_FILE_BUFFER_ARRAY: [40000]u8 = undefined;
pub const GLOBAL_FILE_BUFFER = &GLOBAL_FILE_BUFFER_ARRAY;

var GLOBAL_STDOUT_BUFFER_ARRAY: [1024]u8 = undefined;
pub const GLOBAL_STDOUT_BUFFER = &GLOBAL_STDOUT_BUFFER_ARRAY;

// Windows and Linux compatible version of read line function
pub fn readLine(reader: *Reader) ?[]const u8 {
    const line = (reader.takeDelimiter('\n') catch return null) orelse return null;
    return std.mem.trimEnd(u8, line, "\r");
}

// Generalized A Star algorithm. Many sub-functions must be supplied by caller. Returns final state and cost.
pub fn aStar(
    comptime State: type, // Must be compatible with auto hashing
    comptime Cost: type, // Must be a number
    comptime Context: type,
    // Function to generate next states. Should use provided allocator to create an ArrayList of next states. List is owned by caller.
    comptime nextStateFn: fn (c: Context, s: State, a: Allocator) std.ArrayList(State),
    // Function to determine transition cost to move from first state to second state.
    comptime transitionCostFn: fn (c: Context, s1: State, s2: State) Cost,
    // Function to estimate remaining cost. Must never overestimate actual cost.
    comptime estimateFn: fn (c: Context, s: State) Cost,
    // Function indicating goal is reached
    comptime isSolutionFn: fn (c: Context, s: State) bool,
    comptime hashFn: fn (s: State) u64,
    comptime equalsFn: fn (s1: State, s2: State) bool,
    initialState: State,
    context: Context,
    allocator: Allocator,
) ?Cost {
    const Comparator = struct {
        fn compare(c: Context, a: AStarContext(State, Cost), b: AStarContext(State, Cost)) std.math.Order {
            const aExpected = std.math.add(Cost, a.c, estimateFn(c, a.s)) catch 0;
            const bExpected = std.math.add(Cost, b.c, estimateFn(c, b.s)) catch 0;
            return std.math.order(aExpected, bExpected);
        }
    };
    const HashContext = struct {
        const Self = @This();
        pub fn hash(self: Self, s: State) u64 {
            _ = self;
            return hashFn(s);
        }

        pub fn eql(self: Self, s1: State, s2: State) bool {
            _ = self;
            return equalsFn(s1, s2);
        }
    };

    var priorityQueue = std.PriorityQueue(AStarContext(State, Cost), Context, Comparator.compare).init(allocator, context);
    defer priorityQueue.deinit();
    var seen = std.HashMap(State, Cost, HashContext, 75).init(allocator);
    defer seen.deinit();

    priorityQueue.add(AStarContext(State, Cost){ .s = initialState, .c = 0 }) catch std.debug.print("Failed to add to priority queue", .{});
    seen.put(initialState, 0) catch std.debug.print("Failed to put", .{});

    while (priorityQueue.removeOrNull()) |bestStateCost| {
        if (isSolutionFn(context, bestStateCost.s)) {
            return bestStateCost.c;
        }
        var nextStates = nextStateFn(context, bestStateCost.s, allocator);
        defer nextStates.deinit(allocator);
        for (nextStates.items) |state| {
            const transitionCost = transitionCostFn(context, bestStateCost.s, state);
            const totalCost = std.math.add(Cost, bestStateCost.c, transitionCost) catch 0;
            const existing = seen.get(state);
            if (existing == null or std.math.compare(existing.?, std.math.CompareOperator.gt, totalCost)) {
                const newStateCost = AStarContext(State, Cost){ .s = state, .c = totalCost };
                priorityQueue.add(newStateCost) catch std.debug.print("Failed to add to priority queue", .{});
                seen.put(state, totalCost) catch std.debug.print("Failed to put in hash map", .{});
            }
        }
    }

    return null;
}

// Fixed size array deque
pub fn ArrayDeque(comptime T: type) type {
    return struct {
        items: []T,
        allocator: Allocator,
        head: usize = 0,
        tail: usize = 0,
        size: usize = 0,

        pub fn initWithCapacity(allocator: Allocator, capacity: usize) !ArrayDeque(T) {
            return ArrayDeque(T){ .allocator = allocator, .items = try allocator.alloc(T, capacity) };
        }

        pub fn deinit(self: *ArrayDeque(T)) void {
            self.allocator.free(self.items);
        }

        pub fn addFirst(self: *ArrayDeque(T), item: T) void {
            std.debug.assert(self.size < self.items.len);
            self.head = if (self.head == 0) self.items.len - 1 else self.head - 1;
            self.items[self.head] = item;
            self.size += 1;
        }

        pub fn addLast(self: *ArrayDeque(T), item: T) void {
            std.debug.assert(self.size < self.items.len);
            self.items[self.tail] = item;
            self.tail = if (self.tail >= self.items.len - 1) 0 else self.tail + 1;
            self.size += 1;
        }

        pub fn popFirst(self: *ArrayDeque(T)) ?T {
            if(self.size == 0) {
                return null;
            }
            const result = self.items[self.head];
            self.head = if (self.head >= self.items.len - 1) 0 else self.head + 1;
            self.size -= 1;
            return result;
        }

        pub fn popLast(self: *ArrayDeque(T)) ?T {
            if(self.size == 0) {
                return null;
            }
            self.tail = if (self.tail == 0) self.items.len - 1 else self.tail - 1;
            const result = self.items[self.tail];
            self.size -= 1;
            return result;
        }
    };
}


fn AStarContext(comptime State: type, comptime Cost: type) type {
    return struct {
        s: State,
        c: Cost,
    };
}