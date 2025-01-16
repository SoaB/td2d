const rl = @cImport({
    @cDefine("SUPPORT_GIF_RECORDING", "1");
    @cInclude("Raylib.h");
});

const std = @import("std");
const print = std.debug.print;

const g_timer = @import("GameTimer.zig");
// game config
const g_cfgs = @import("Configs.zig");
const grid_w = g_cfgs.GRID_WIDTH;
const grid_h = g_cfgs.GRID_HEIGHT;
const board_x = (g_cfgs.SCR_WIDTH - g_cfgs.GRID_WIDTH * g_cfgs.GRID_SIZE) / 2;
const board_y = (g_cfgs.SCR_HEIGHT - g_cfgs.GRID_HEIGHT * g_cfgs.GRID_SIZE) / 2;
//Enemys
const Enemys = @import("Enemys.zig");
const EnemyType = Enemys.EnemyType;
// Projectiles
const Projectiles = @import("Projectiles.zig");
const ProjectileType = Projectiles.ProjectileType;
// Vector2
const Vec2f = @import("Vector2.zig").Vec2f;
// TowerType enum
pub const TowerType = enum {
    NONE,
    BASE,
    GUN,
};
// Tower struct definition
pub const Tower = struct {
    pos: Vec2f,
    cool_down: f32,
    tower_type: TowerType,
};
// Towers array definition
pub const MAX_TOWERS_COUNTER = 100;
var items: [MAX_TOWERS_COUNTER]Tower = undefined;
var counter: u32 = 0;

pub fn init() void {
    for (&items) |*item| {
        item.* = Tower{
            .pos = Vec2f{ .x = 0.0, .y = 0.0 },
            .cool_down = 0.0,
            .tower_type = TowerType.NONE,
        };
    }
    counter = 0;
}
pub fn canPlaceTower(position: Vec2f) bool {
    for (0..counter) |i| {
        if (items[i].pos.x == position.x and items[i].pos.y == position.y) {
            return false;
        }
    }
    return true;
}
pub fn tryAdd(position: Vec2f, tower_type: TowerType) void {
    if (counter >= MAX_TOWERS_COUNTER) {
        return;
    }
    if (counter == 0) {
        items[counter] = Tower{
            .pos = position,
            .cool_down = 0.0,
            .tower_type = tower_type,
        };
        counter += 1;
        return;
    }
    if (canPlaceTower(position)) {
        items[counter] = Tower{
            .pos = position,
            .cool_down = 0.0,
            .tower_type = tower_type,
        };
        counter += 1;
    }
}
pub fn remove(position: Vec2f) void {
    for (0..counter) |i| {
        if (items[i].pos.x == position.x and items[i].pos.y == position.y) {
            items[i] = Tower{
                .pos = Vec2f{ 0.0, 0.0 },
                .cool_down = 0.0,
                .tower_type = TowerType.NONE,
            };
            counter -= 1;
            return;
        }
    }
}
pub fn draw() void {
    const block_size: rl.Vector2 = rl.Vector2{ .x = grid_w * 0.6, .y = grid_h * 0.6 };
    for (0..counter) |i| {
        const x: f32 = items[i].pos.x * grid_w + board_x;
        const y: f32 = items[i].pos.y * grid_h + board_y;
        const pos = rl.Vector2{ .x = x, .y = y };
        const pos1 = rl.Vector2{ .x = x + grid_w * 0.2, .y = y + grid_h * 0.2 };
        rl.DrawRectangleV(pos, rl.Vector2{ .x = grid_w, .y = grid_h }, rl.RED);
        switch (items[i].tower_type) {
            .BASE => rl.DrawRectangleV(pos1, block_size, rl.BLUE),
            .GUN => rl.DrawRectangleV(pos1, block_size, rl.GREEN),
            else => {},
        }
    }
}
// get BASE tower position
pub fn getBasePos() Vec2f {
    for (0..counter) |i| {
        if (items[i].tower_type == TowerType.BASE) {
            return items[i].pos;
        }
    }
    return Vec2f{ .x = 0.0, .y = 0.0 };
}
// update towers
pub fn update() void {
    for (0..counter) |i| {
        const tower: *Tower = &items[i];
        switch (tower.*.tower_type) {
            .GUN => {
                gunUpdate(tower);
            },
            else => {},
        }
    }
}
// gun tower update
fn gunUpdate(tower: *Tower) void {
    if (tower.*.cool_down < 0.0) {
        const index: ?usize = Enemys.getClosest(tower.*.pos, getBasePos(), 3.0);
        if (index) |i| {
            tower.*.cool_down = 0.25;
            // shoot enemy determine feture position
            const bullet_speed: f32 = 5.0;
            const bullet_damage: f32 = 3.0;
            var velocity = Enemys.getVelocity(i);
            var tmp_way_count: usize = 0;
            var future_pos = Enemys.getPosi(i, Enemys.getPastTime(i), &velocity, &tmp_way_count);
            const tower_pos = tower.*.pos;
            var eta: f32 = Vec2f.distance(future_pos, tower_pos) / bullet_speed;
            for (0..8) |_| {
                velocity = Enemys.getVelocity(i);
                future_pos = Enemys.getPosi(i, Enemys.getPastTime(i) + eta, &velocity, &tmp_way_count);
                const distance: f32 = Vec2f.distance(future_pos, tower_pos);
                const eta2: f32 = distance / bullet_speed;
                if (@abs(eta - eta2) < 0.01) {
                    break;
                }
                eta = (eta2 + eta) * 0.5;
            }
            Projectiles.tryAdd(ProjectileType.BULLET, i, tower_pos, future_pos, bullet_speed, bullet_damage);
            Enemys.addFetureDamage(i, bullet_damage);
        }
    } else {
        tower.*.cool_down -= g_timer.getDeltaTime();
    }
}
