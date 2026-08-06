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
pub fn aStarAuto(
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

    var priorityQueue = std.PriorityQueue(AStarContext(State, Cost), Context, Comparator.compare).initContext(context);
    defer priorityQueue.deinit(allocator);
    var seen = std.AutoHashMap(State, Cost).init(allocator);
    defer seen.deinit();

    priorityQueue.push(allocator, AStarContext(State, Cost){ .s = initialState, .c = 0 }) catch std.debug.print("Failed to add to priority queue", .{});
    seen.put(initialState, 0) catch std.debug.print("Failed to put", .{});

    while (priorityQueue.pop()) |bestStateCost| {
        //std.debug.print("{any}\n",.{bestStateCost.s});
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
                priorityQueue.push(allocator, newStateCost) catch std.debug.print("Failed to add to priority queue", .{});
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

// Map of key to slice of values. Returns empty slice if key not present.
// Keys must be auto-hashable
pub fn Multimap(comptime KeyType: type, comptime ValueType: type) type {
    return struct {
        map: std.AutoHashMap(KeyType, *std.ArrayList(ValueType)),
        allocator: Allocator,

        pub fn init(allocator: Allocator) Multimap(KeyType, ValueType) {
            return Multimap(KeyType, ValueType){ .map = std.AutoHashMap(KeyType, *std.ArrayList(ValueType)).init(allocator), .allocator = allocator };
        }

        pub fn get(self: *Multimap(KeyType, ValueType), key: KeyType) []ValueType {
            if (self.map.get(key)) |existing| {
                return existing.items;
            } else {
                return &.{};
            }
        }

        pub fn put(self: *Multimap(KeyType, ValueType), key: KeyType, value: ValueType) !void {
            if (self.map.get(key)) |existing| {
                try existing.append(self.allocator, value);
            } else {
                const list = try self.allocator.create(std.ArrayList(ValueType));
                list.* = std.ArrayList(ValueType).empty;
                try list.append(self.allocator, value);
                try self.map.put(key, list);
            }
        }

        pub fn contains(self: *Multimap(KeyType, ValueType), key: KeyType) bool {
            return self.map.contains(key);
        }

        // Removes element at index. Does not preserve item order
        pub fn remove(self: *Multimap(KeyType, ValueType), key: KeyType, index: usize) void {
            if (self.map.get(key)) |list| {
                _ = list.swapRemove(index);
            }
        }

        pub fn removeKey(self: *Multimap(KeyType, ValueType), key: KeyType) void {
            if (self.map.get(key)) |val| {
                val.deinit(self.allocator);
                self.allocator.destroy(val);
            }
            _ = self.map.remove(key);
        }

        pub fn keyCount(self: *Multimap(KeyType, ValueType)) u64 {
            return @intCast(self.map.count());
        }

        pub fn keyIterator(self: *Multimap(KeyType, ValueType)) std.AutoHashMap(KeyType, *std.ArrayList(ValueType)).KeyIterator {
            return self.map.keyIterator();
        }

        pub fn deinit(self: *Multimap(KeyType, ValueType)) void {
            var it = self.map.valueIterator();
            while (it.next()) |next| {
                next.*.deinit();
                self.allocator.destroy(next.*);
            }
            self.map.deinit();
        }
    };
}


fn AStarContext(comptime State: type, comptime Cost: type) type {
    return struct {
        s: State,
        c: Cost,
    };
}
