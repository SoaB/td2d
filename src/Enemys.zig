const rl = @cImport({
    @cDefine("SUPPORT_GIF_RECORDING", "1");
    @cInclude("Raylib.h");
});

const std = @import("std");
const print = std.debug.print;
const g_timer = @import("GameTimer.zig");
const Vec2f = @import("Vector2.zig").Vec2f;
// game config
const g_cfgs = @import("Configs.zig");
const grid_w = g_cfgs.GRID_WIDTH;
const grid_h = g_cfgs.GRID_HEIGHT;
const board_x = (g_cfgs.SCR_WIDTH - g_cfgs.GRID_WIDTH * g_cfgs.GRID_SIZE) / 2;
const board_y = (g_cfgs.SCR_HEIGHT - g_cfgs.GRID_HEIGHT * g_cfgs.GRID_SIZE) / 2;
// Towers module
const Towers = @import("Towers.zig");
// Enemy types
pub const EnemyType = enum {
    NONE,
    MIMION,
};
// Enemy types config
const EnemyCfg = struct {
    health: f32 = 1,
    speed: f32 = 1.0,
    radius: f32 = 1.0,
    max_accele: f32 = 1.0,
};
const enemy_cfgs = [_]EnemyCfg{
    EnemyCfg{
        .health = 0.0,
        .speed = 0.0,
        .radius = 0.0,
        .max_accele = 0.0,
    },
    EnemyCfg{
        .health = 3.0,
        .speed = 1.0,
        .radius = 0.25,
        .max_accele = 1.0,
    },
};
// Enemy id
pub const EnemyId = struct {
    index: usize,
    generation: u32,
};
// Enemy struct
const Enemy = struct {
    posi: Vec2f = Vec2f.new(0, 0),
    next_posi: Vec2f = Vec2f.new(0, 0),
    sim_posi: Vec2f = Vec2f.new(0, 0),
    sim_velocity: Vec2f = Vec2f.new(0, 0),
    start_moving_time: f32 = 0,
    generation: u32 = 0,
    damage: f32 = 0,
    feture_damage: f32 = 0,
    enemy_type: EnemyType = EnemyType.NONE,
};
// Enemy list
const ENEMY_MAX_COUNT = 100;
var items: [ENEMY_MAX_COUNT]Enemy = undefined;
var item_count: usize = 0;
// EnemyId functions
pub fn getEnemyId(index: usize) EnemyId {
    const generation: u32 = items[index].generation;
    return EnemyId{
        .index = index,
        .generation = generation,
    };
}
// EnemyId functions try Resolve
pub fn tryResolveEnemyId(id: EnemyId) ?usize {
    if (id.index >= ENEMY_MAX_COUNT) return null;
    const item = items[id.index];
    if (item.generation != id.generation or item.enemy_type == EnemyType.NONE) {
        return null;
    }
    return id.index;
}
// Enemy functions
pub fn init() void {
    item_count = 0;
    for (&items) |*item| {
        item.* = Enemy{
            .posi = Vec2f.new(0, 0),
            .next_posi = Vec2f.new(0, 0),
            .start_moving_time = 0,
            .generation = 0,
            .damage = 0,
            .feture_damage = 0,
            .enemy_type = EnemyType.NONE,
        };
    }
}
// try to add a new enemy
pub fn tryAdd(posi: Vec2f, tpe: EnemyType) void {
    if (item_count >= ENEMY_MAX_COUNT) return;
    var enemy: Enemy = undefined;
    enemy.posi = posi;
    enemy.next_posi = posi;
    enemy.sim_posi = posi;
    enemy.sim_velocity = Vec2f.new(0, 0);
    enemy.start_moving_time = g_timer.getTime();
    enemy.generation += 1;
    enemy.damage = 0;
    enemy.feture_damage = 0;
    enemy.enemy_type = tpe;
    if (item_count == 0) {
        items[0] = enemy;
        item_count += 1;
        return;
    }
    for (0..item_count) |i| {
        if (items[i].enemy_type == EnemyType.NONE) {
            items[i] = enemy;
            return;
        }
    }
    for (item_count..ENEMY_MAX_COUNT) |i| {
        if (items[i].enemy_type == EnemyType.NONE) {
            items[i] = enemy;
            item_count += 1;
            return;
        }
    }
}
// remove an enemy by index
pub fn remove(index: usize) void {
    if (index >= item_count) return;
    items[index] = Enemy{
        .posi = Vec2f.new(0, 0),
        .next_posi = Vec2f.new(0, 0),
        .start_moving_time = 0,
        .generation = 0,
        .enemy_type = EnemyType.NONE,
    };
    if (index == item_count - 1) {
        item_count -= 1;
    }
}
// get enemy count
pub fn getEnemyCount() usize {
    var count: usize = 0;
    for (0..item_count) |i| {
        if (items[i].enemy_type != EnemyType.NONE) {
            count += 1;
        }
    }
    return count;
}
// get enemy position by index
pub fn getPosByIndex(index: usize) Vec2f {
    return items[index].posi;
}
// get max accele
pub fn getMaxAccele(tpe: EnemyType) f32 {
    switch (tpe) {
        EnemyType.MIMION => {
            return enemy_cfgs[@intFromEnum(tpe)].max_accele;
        },
        else => return 1.0,
    }
    return 1.0;
}
// get enemy radius
pub fn getRadius(tpe: EnemyType) f32 {
    switch (tpe) {
        EnemyType.MIMION => {
            return enemy_cfgs[@intFromEnum(tpe)].radius;
        },
        else => return 1.0,
    }
    return 1.0;
}
// get enemy velocity
pub fn getVelocity(index: usize) Vec2f {
    return items[index].sim_velocity;
}
// get enemy speed
pub fn getSpeed(tpe: EnemyType) f32 {
    switch (tpe) {
        EnemyType.MIMION => {
            return enemy_cfgs[@intFromEnum(tpe)].speed;
        },
        else => return 1.0,
    }
    return 1.0;
}
// get enemy health
pub fn getMaxHealth(tpe: EnemyType) f32 {
    switch (tpe) {
        EnemyType.MIMION => {
            return enemy_cfgs[@intFromEnum(tpe)].health;
        },
        else => return 1,
    }
    return 1;
}
// get enemy past time
pub fn getPastTime(index: usize) f32 {
    return g_timer.getTime() - items[index].start_moving_time;
}
// add damage to an enemy
pub fn addDamage(index: usize, damage: f32) void {
    items[index].damage += damage;
    if (items[index].damage >= getMaxHealth(items[index].enemy_type)) {
        remove(index);
    }
}
// add feture damage to an enemy
pub fn addFetureDamage(index: usize, damage: f32) void {
    items[index].feture_damage += damage;
}
// calc next position of an enemy
pub fn calcNextPosi(curr: Vec2f, next: *Vec2f) bool {
    const base_pos: Vec2f = Towers.getBasePos();
    const dx: f32 = base_pos.x - curr.x;
    const dy: f32 = base_pos.y - curr.y;
    if (dx == 0 and dy == 0) {
        // enemy is at the castle, remove it
        next.* = curr;
        return true;
    }
    if (@abs(dx) > @abs(dy)) {
        if (dx > 0) {
            next.* = Vec2f.new(curr.x + 1, curr.y);
        } else {
            next.* = Vec2f.new(curr.x - 1, curr.y);
        }
    } else {
        if (dy > 0) {
            next.* = Vec2f.new(curr.x, curr.y + 1);
        } else {
            next.* = Vec2f.new(curr.x, curr.y - 1);
        }
    }
    return false;
}
// get position
pub fn getPosi(index: usize, delta_t: f32, velocity: *Vec2f, way_point_count: *usize) Vec2f {
    const point_reach_distance: f32 = 0.25;
    const point_reach_distance_sq: f32 = point_reach_distance * point_reach_distance;
    const max_sim_step_time: f32 = 0.015625;
    //
    const max_accele: f32 = getMaxAccele(items[index].enemy_type);
    const max_speeed: f32 = getSpeed(items[index].enemy_type);

    var next_pos = items[index].next_posi;
    var posi = items[index].sim_posi;
    var passed_count: usize = 0;
    var t: f32 = 0;
    while (t < delta_t) : (t += max_sim_step_time) {
        const step_time: f32 = @min(delta_t - t, max_sim_step_time);
        var target_pos: Vec2f = next_pos;
        const speed: f32 = Vec2f.len(velocity.*);
        // draw target position for debug
        //const tp: Vec2f = g_cfgs.grid2scr(target_pos);
        //        print("target pos: ({d:2.2}, {d:2.2})\n", .{ tp.x, tp.y });
        //        rl.DrawRectangleV(rl.Vector2{ .x = tp.x, .y = tp.y }, rl.Vector2{ .x = grid_w, .y = grid_h }, rl.BLACK);
        const look_forward_pos: Vec2f = Vec2f.add(posi, Vec2f.scale(velocity.*, speed));
        if (Vec2f.distanceSquared(posi, target_pos) <= point_reach_distance_sq) {
            // reach the target position, move to next position
            _ = calcNextPosi(next_pos, &next_pos);
            target_pos = next_pos;
            // track way points
            passed_count += 1;
        }
        // acceleration toward to target position
        const unit_direction: Vec2f = Vec2f.normalize(Vec2f.sub(target_pos, look_forward_pos));
        const accele: Vec2f = Vec2f.scale(unit_direction, max_accele * step_time);
        velocity.* = Vec2f.add(velocity.*, accele);
        // limit velocity
        if (speed > max_speeed) {
            velocity.* = Vec2f.scale(velocity.*, max_speeed / speed);
        }
        // move position
        posi = Vec2f.add(posi, Vec2f.scale(velocity.*, step_time));
        way_point_count.* = passed_count;
    }
    return posi;
}
// draw all enemies
pub fn draw() void {
    var way_point_count: usize = 0;
    for (0..item_count) |i| {
        const item = &items[i];
        if (item.*.enemy_type == EnemyType.NONE) {
            continue;
        }
        const spos: Vec2f = getPosi(i, getPastTime(i), &item.*.sim_velocity, &way_point_count);
        const g2s: Vec2f = g_cfgs.grid2scr(spos);
        const pos = rl.Vector2{ .x = g2s.x, .y = g2s.y };
        switch (item.*.enemy_type) {
            EnemyType.MIMION => {
                rl.DrawRectangleV(pos, rl.Vector2{ .x = grid_w, .y = grid_h }, rl.LIGHTGRAY);
            },
            else => {},
        }
    }
}
// update all enemies
pub fn update() void {
    const castle_pos: Vec2f = Towers.getBasePos();
    for (0..item_count) |i| {
        const item: *Enemy = &items[i];
        if (item.*.enemy_type == EnemyType.NONE) {
            continue;
        }
        var way_point_count: usize = 0;
        item.*.sim_posi = getPosi(i, g_timer.getTime() - item.*.start_moving_time, &item.*.sim_velocity, &way_point_count);
        item.*.start_moving_time = g_timer.getTime();
        if (way_point_count > 0) {
            item.*.posi = item.*.next_posi;
            if (calcNextPosi(item.*.posi, &item.*.next_posi) and
                Vec2f.distanceSquared(item.*.sim_posi, castle_pos) <= 0.25 * 0.25)
            {
                // enemy is at the castle, remove it
                remove(i);
                continue;
            }
        }
    }
    handleCollision();
}
// Spawn a new enemy
pub fn spawn(tpe: EnemyType) void {
    const randVal: i32 = rl.GetRandomValue(0, 19);
    const randSide: i32 = rl.GetRandomValue(0, 3);
    var x: i32 = 0;
    var y: i32 = 0;
    if (randSide == 0) {
        x = 0;
    } else if (randSide == 1) {
        x = 19;
    } else {
        x = randVal;
    }
    if (randSide == 2) {
        y = 0;
    } else if (randSide == 3) {
        y = 19;
    } else {
        y = randVal;
    }
    const px: f32 = @as(f32, @floatFromInt(x));
    const py: f32 = @as(f32, @floatFromInt(y));
    const posi = Vec2f.new(px, py);
    tryAdd(posi, tpe);
}
// get closet enemy to a target
pub fn getClosest(from: Vec2f, to: Vec2f, range: f32) ?usize {
    const target_x: f32 = to.x;
    const target_y: f32 = to.y;
    var closest_dist: f32 = 0.0;
    const range_sq: f32 = range * range;
    var closest_index: ?usize = null;
    for (0..item_count) |i| {
        const item = items[i];
        if (item.enemy_type == .NONE) {
            continue;
        }
        const max_health: f32 = getMaxHealth(item.enemy_type);
        if (item.feture_damage >= max_health) {
            // enemy is already dead
            continue;
        }
        const dx: f32 = target_x - item.posi.x;
        const dy: f32 = target_y - item.posi.y;
        const dist: f32 = @abs(dx) + @abs(dy);
        if (closest_index == null or dist < closest_dist) {
            const fdist_sq: f32 = Vec2f.lenSquare(Vec2f.sub(from, item.posi));
            if (fdist_sq < range_sq) {
                closest_dist = dist;
                closest_index = i;
            }
        }
    }
    return closest_index;
}

pub fn handleCollision() void {
    for (0..item_count - 1) |i| {
        const item = &items[i];
        if (item.*.enemy_type == EnemyType.NONE) {
            continue;
        }
        for (i + 1..item_count) |j| {
            const other = &items[j];
            if (other.*.enemy_type == EnemyType.NONE) {
                continue;
            }
            if (item.*.enemy_type != other.*.enemy_type) {
                continue;
            }
            const pa: Vec2f = Vec2f.add(item.*.sim_posi, Vec2f.scale(item.*.sim_velocity, 0.5));
            const pb: Vec2f = Vec2f.add(other.*.sim_posi, Vec2f.scale(other.*.sim_velocity, 0.5));
            const distance_sqr: f32 = Vec2f.distanceSquared(pa, pb);
            const radiua_a: f32 = getRadius(item.*.enemy_type);
            const radiua_b: f32 = getRadius(other.*.enemy_type);
            const radiua_sum: f32 = radiua_a + radiua_b;
            if (distance_sqr <= radiua_sum * radiua_sum and distance_sqr > 0.001) {
                // collision
                const distance: f32 = @sqrt(distance_sqr);
                const over_lap: f32 = radiua_sum - distance;
                // move away from each other
                const position_correction: f32 = over_lap / 5.0;
                const dd: f32 = 1.0 / (distance * position_correction);
                const direction: Vec2f = Vec2f.scale(Vec2f.sub(other.*.sim_posi, item.*.sim_posi), dd);
                item.*.sim_posi = Vec2f.add(item.*.sim_posi, direction);
                other.*.sim_posi = Vec2f.sub(other.*.sim_posi, direction);
            }
        }
    }
}
