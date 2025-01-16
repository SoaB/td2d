const std = @import("std");
// Simple Queue type
// initialize
//    var queue = SimpleQueue(i32){};
//    try queue.init(std.heap.page_allocator);
// release memory
//    defer queue.deinit();

pub fn SimpleQueue(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T = undefined,
        numsCapacity: usize = 64,
        numSize: usize = 0,
        extendRatio: usize = 2,
        mem_arena: ?std.heap.ArenaAllocator = null,
        mem_allocator: std.mem.Allocator = undefined,

        pub fn init(self: *Self, allocator: std.mem.Allocator) !void {
            if (self.mem_arena == null) {
                self.mem_arena = std.heap.ArenaAllocator.init(allocator);
                self.mem_allocator = self.mem_arena.?.allocator();
            }
            self.items = try self.mem_allocator.alloc(T, self.numsCapacity);
        }

        pub fn deinit(self: *Self) void {
            if (self.mem_arena == null) return;
            self.mem_arena.?.deinit();
        }

        pub fn size(self: *Self) usize {
            return self.numSize;
        }
        pub fn resetSize(self: *Self) void {
            self.numSize = 0;
        }
        pub fn capacity(self: *Self) usize {
            return self.numsCapacity;
        }
        pub fn add(self: *Self, num: T) !void {
            if (self.size() == self.capacity()) try self.extendCapacity();
            self.items[self.size()] = num;
            self.numSize += 1;
        }
        pub fn insert(self: *Self, index: usize, num: T) !void {
            if (index < 0 or index >= self.size()) @panic("index out of range");
            if (self.size() == self.capacity()) try self.extendCapacity();
            var j = self.size() - 1;
            while (j >= index) : (j -= 1) {
                self.items[j + 1] = self.nums[j];
            }
            self.items[index] = num;
            self.numSize += 1;
        }
        pub fn pop(self: *Self) ?T {
            if (self.size() == 0) return null;
            const num: ?T = self.items[0];
            if (num) |n| {
                for (1..self.numSize) |j| {
                    self.items[j - 1] = self.items[j];
                }
                self.numSize -= 1;
                return n;
            }
            return null;
        }
        pub fn remove(self: *Self, index: usize) T {
            if (index < 0 or index >= self.size()) @panic("index out of range");
            const num = self.items[index];
            var j = index;
            while (j < self.size() - 1) : (j += 1) {
                self.items[j] = self.items[j + 1];
            }
            self.numSize -= 1;
            return num;
        }
        pub fn extendCapacity(self: *Self) !void {
            const newCapacity = self.capacity() * self.extendRatio;
            const extend = try self.mem_allocator.alloc(T, newCapacity);
            std.mem.copyForwards(T, extend, self.items);
            self.items = extend;
            self.numsCapacity = newCapacity;
        }
        pub fn toArray(self: *Self) ![]T {
            const nums = try self.mem_allocator.alloc(T, self.size());
            for (nums, 0..) |*num, i| {
                num.* = self.get(i);
            }
            return nums;
        }
    };
}
