const rl = @cImport({
    @cDefine("SUPPORT_GIF_RECORDING", "1");
    @cInclude("Raylib.h");
});

const std = @import("std");
const print = std.debug.print;

const SimpleQueue = @import("SimpleQueue.zig").SimpleQueue;

const Vec3f = @import("Vector3.zig").Vec3f;
const Vec2f = @import("Vector2.zig").Vec2f;
const mat = @import("Math3D.zig");
const Matrix = mat.Matrix;
const g_timer = @import("GameTimer.zig");

const Towers = @import("tower.zig").Towers;
const towerType = @import("tower.zig").TowerType;

// Pathfinding map
pub const DeltaSrc = struct {
    x: i32,
    y: i32,
};
pub const PathfindingMap = struct {
    width: i32 = 0,
    height: i32 = 0,
    scale: f32 = 1.0,
    distances: []f32 = undefined,
    tower_index: []i32 = undefined,
    delta_src: []DeltaSrc = undefined,
    max_distance: f32 = 0.0,
    to_map_space: Matrix,
    to_world_space: Matrix,
    allocator: std.mem.Allocator,
};

// when we execute the pathfinding algorithm, we need to store the active nodes
// in a queue. Each node has a position, a distance from the start, and the
// position of the node that we came from (currently not used)
pub const PathfindingNode = struct {
    x: i32,
    y: i32,
    from_x: i32,
    from_y: i32,
    distance: f32,
};

// The queue is a simple array of nodes, we add nodes to the end and remove
// nodes from the front. We keep the array around to avoid unnecessary allocations
var pfNodeQueue: SimpleQueue(PathfindingNode) = SimpleQueue(PathfindingNode){};
// The pathfinding map stores the distances from the castle to each cell in the map.
var pfMap: PathfindingMap = undefined;

pub fn mapInit(allocator: std.mem.Allocator, w: i32, h: i32, translate: Vec3f, scale: f32) void {
    // transforming between map space and world space allows us to adapt
    // position and scale of the map without changing the pathfinding data
    pfMap.allocator = allocator;
    pfMap.to_world_space = mat.translate(translate.x, translate.y, translate.z);
    pfMap.to_world_space = mat.multiply(pfMap.to_world_space, mat.scale(scale, scale, scale));
    pfMap.to_map_space = mat.invert(pfMap.to_world_space);
    pfMap.width = w;
    pfMap.height = h;
    pfMap.scale = scale;
    const len: usize = @intCast(w * h);
    var mem_distances: []f32 = pfMap.allocator.alloc(f32, len) catch @panic("Memory allocation failed");
    var mem_tower_index: []i32 = pfMap.allocator.alloc(i32, len) catch @panic("Memory allocation failed");
    var mem_delta_src: []DeltaSrc = pfMap.allocator.alloc(DeltaSrc, len) catch @panic("Memory allocation failed");
    @memset(mem_distances[0..], 0.0);
    @memset(mem_tower_index[0..], -1);
    @memset(mem_delta_src[0..], DeltaSrc{ .x = 0, .y = 0 });
    pfMap.distances = mem_distances[0..];
    pfMap.tower_index = mem_tower_index[0..];
    pfMap.delta_src = mem_delta_src[0..];
    pfMap.max_distance = 0.0;
    pfNodeQueue.init(allocator) catch @panic("Memory allocation failed");
}
pub fn mapDeinit() void {
    pfMap.allocator.free(pfMap.distances);
    pfMap.allocator.free(pfMap.tower_index);
    pfMap.allocator.free(pfMap.delta_src);
    pfNodeQueue.deinit();
}
pub fn getDistance(x: i32, y: i32) f32 {
    if (x < 0 or x >= pfMap.width or y < 0 or y >= pfMap.height) {
        return @abs(@as(f32, @floatFromInt(x))) + @abs(@as(f32, @floatFromInt(y)));
    }
    const index: usize = @intCast(y * pfMap.width + x);
    return pfMap.distances[index];
}
fn nodePush(x: i32, y: i32, from_x: i32, from_y: i32, distance: f32) void {
    const node: PathfindingNode = PathfindingNode{
        .x = x,
        .y = y,
        .from_x = from_x,
        .from_y = from_y,
        .distance = distance,
    };
    pfNodeQueue.add(node) catch @panic("Memory allocation failed");
}

fn nodePop() ?PathfindingNode {
    return pfNodeQueue.pop();
}
// transform a world position to a map position in the array;
// returns true if the position is inside the map
fn fromWorldToMapPosition(world_position: Vec3f, map_x: *i32, map_y: *i32) bool {
    const map_position: Vec3f = Vec3f.transform(world_position, pfMap.to_map_space);
    map_x.* = @intFromFloat(map_position.x);
    map_y.* = @intFromFloat(map_position.z);
    return map_x.* >= 0 and map_x.* < pfMap.width and map_y.* >= 0 and map_y.* < pfMap.height;
}

pub fn mapUpdate() void {
    const castle_x: i32 = 0;
    const castle_y: i32 = 0;
    var castle_map_x: i32 = 0;
    var castle_map_y: i32 = 0;
    if (!fromWorldToMapPosition(Vec3f{ .x = castle_x, .y = 0.0, .z = castle_y }, &castle_map_x, &castle_map_y)) {
        return;
    }
    const width: i32 = pfMap.width;
    const height: i32 = pfMap.height;

    // reset the distances to -1
    const len: usize = @intCast(width * height);
    for (0..len - 1) |i| {
        pfMap.distances[i] = -1.0;
        pfMap.tower_index[i] = -1;
        pfMap.delta_src[i] = DeltaSrc{ .x = 0, .y = 0 };
    }
    for (Towers.towers, 0..Towers.count) |tower, i| {
        if (tower.tower_type == towerType.BASE or tower.tower_type == towerType.NONE) {
            continue;
        }
        var tower_map_x: i32 = 0;
        var tower_map_y: i32 = 0;
        // technically, if the tower cell scale is not in sync with the pathfinding map scale,
        // this would not work correctly and needs to be refined to allow towers covering multiple cells
        // or having multiple towers in one cell; for simplicity, we assume that the tower covers exactly
        // one cell. For now, we just assume that the tower is always in the center of its cell.
        if (!fromWorldToMapPosition(Vec3f{ .x = @floatFromInt(tower.x), .y = 0.0, .z = @floatFromInt(tower.y) }, &tower_map_x, &tower_map_y)) {
            continue;
        }
        const tower_index: usize = @intCast(tower_map_y * width + tower_map_x);
        pfMap.tower_index[tower_index] = @intCast(i);
    }
    // we start at the castle and add the castle to the queue
    pfMap.max_distance = 0.0;
    pfNodeQueue.resetSize();
    nodePush(castle_map_x, castle_map_y, castle_map_x, castle_map_y, 0.0);
    var nod: ?PathfindingNode = nodePop();
    while (nod) |*node| {
        if (node.*.x < 0 or node.*.x >= width or node.*.y < 0 or node.*.y >= height) {
            nod = nodePop();
            continue;
        }
        const index: usize = @intCast(node.*.y * width + node.*.x);
        if (pfMap.distances[index] >= 0 and pfMap.distances[index] <= node.*.distance) {
            nod = nodePop();
            continue;
        }
        const delta_x: i32 = node.*.x - node.*.from_x;
        const delta_y: i32 = node.*.y - node.*.from_y;
        // even if the cell is blocked by a tower, we still may want to store the direction
        // (though this might not be needed, IDK right now)
        pfMap.delta_src[index] = DeltaSrc{ .x = delta_x, .y = delta_y };
        if (pfMap.tower_index[index] >= 0) {
            node.*.distance += 8.0;
            //            nod = nodePop();
            //            continue;
        }
        pfMap.distances[index] = node.*.distance;
        pfMap.max_distance = @max(pfMap.max_distance, node.*.distance);
        nodePush(node.*.x, node.*.y + 1, node.*.x, node.*.y, node.*.distance + 1.0);
        nodePush(node.*.x, node.*.y - 1, node.*.x, node.*.y, node.*.distance + 1.0);
        nodePush(node.*.x + 1, node.*.y, node.*.x, node.*.y, node.*.distance + 1.0);
        nodePush(node.*.x - 1, node.*.y, node.*.x, node.*.y, node.*.distance + 1.0);
        nod = nodePop();
    }
}

pub fn mapDraw() void {
    const cell_size: f32 = pfMap.scale * 0.9;
    const highlight_distance: f32 = @mod(gameTime.getTime() * 4.0, pfMap.max_distance);
    for (0..@as(usize, @intCast(pfMap.width - 1))) |x| {
        for (0..@as(usize, @intCast(pfMap.height - 1))) |y| {
            const index: usize = y * @as(usize, @intCast(pfMap.width)) + x;
            const distance: f32 = pfMap.distances[index];
            const color_v: f32 = if (distance < 0) 0 else @min(distance / pfMap.max_distance, 1.0);
            var color: rl.Color = if (distance < 0) rl.BLUE else rl.Color{ .r = @as(u8, @intFromFloat(@min(color_v, 1.0) * 255)), .g = 0, .b = 0, .a = 255 };
            const position: Vec3f = Vec3f.transform(Vec3f{ .x = @as(f32, @floatFromInt(x)), .y = -0.25, .z = @as(f32, @floatFromInt(y)) }, pfMap.to_world_space);
            // animate the distance "wave" to show how the pathfinding algorithm expands
            // from the castle
            if (distance + 0.5 > highlight_distance and distance - 0.5 < highlight_distance) {
                color = rl.YELLOW;
            }
            const pos: rl.Vector3 = rl.Vector3{ .x = position.x, .y = position.y, .z = position.z };
            rl.DrawCube(pos, cell_size, 0.1, cell_size, color);
        }
    }
}
pub fn getGradient(world: Vec3f) Vec2f {
    var map_x: i32 = 0;
    var map_y: i32 = 0;
    if (fromWorldToMapPosition(world, &map_x, &map_y)) {
        const index: usize = @intCast(map_y * pfMap.width + map_x);
        const delta: DeltaSrc = pfMap.delta_src[index];
        const dx: f32 = @floatFromInt(delta.x);
        const dy: f32 = @floatFromInt(delta.y);
        return Vec2f{ .x = -dx, .y = -dy };
    }
    const n: f32 = getDistance(map_x, map_y - 1);
    const s: f32 = getDistance(map_x, map_y + 1);
    const e: f32 = getDistance(map_x + 1, map_y);
    const w: f32 = getDistance(map_x - 1, map_y);
    return Vec2f{ .x = w - e + 0.25, .y = n - s + 0.125 };
}
pub fn mapPrint() void {
    for (0..@as(usize, @intCast(pfMap.width - 1))) |x| {
        for (0..@as(usize, @intCast(pfMap.height - 1))) |y| {
            const index: usize = y * @as(usize, @intCast(pfMap.width)) + x;
            const distance: f32 = pfMap.distances[index];
            print("{d:2.2} ", .{distance});
        }
        print("x = {d:2.2}\n", .{x});
    }
}
