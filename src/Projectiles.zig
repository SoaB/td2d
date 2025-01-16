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
// enemys
const Enemys = @import("Enemys.zig");
const EnemyId = Enemys.EnemyId;
const EnemyType = Enemys.EnemyType;
// projectiles

const MAX_PROJECTILES = 1000;
pub const ProjectileType = enum {
    NONE,
    BULLET,
};

pub const Projectile = struct {
    typ: ProjectileType,
    shoot_time: f32,
    arrived_time: f32,
    damage: f32,
    pos: Vec2f,
    target: Vec2f,
    direction_norm: Vec2f,
    target_enemy: EnemyId,
};
// projectiles global variables
var items: [MAX_PROJECTILES]Projectile = undefined;
var num_items: usize = 0;
// projectiles functions
pub fn init() void {
    num_items = 0;
    for (&items) |*item| {
        item.* = .{
            .typ = ProjectileType.NONE,
            .shoot_time = 0,
            .arrived_time = 0,
            .damage = 0,
            .pos = Vec2f.zero(),
            .target = Vec2f.zero(),
            .direction_norm = Vec2f.zero(),
            .target_enemy = undefined,
        };
    }
}
pub fn draw() void {
    for (items[0..num_items]) |item| {
        if (item.typ == ProjectileType.NONE) {
            continue;
        }
        const transition: f32 = (g_timer.getTime() - item.shoot_time) / (item.arrived_time - item.shoot_time);
        if (transition >= 1.0) {
            continue;
        }
        const pos = item.pos.lerp(item.target, transition);
        const cp: Vec2f = g_cfgs.grid2scrCenter(pos);
        const r: f32 = 3;
        rl.DrawCircleV(rl.Vector2{ .x = cp.x, .y = cp.y }, r, rl.WHITE);
    }
}

pub fn update() void {
    for (items[0..num_items]) |*item| {
        if (item.typ == ProjectileType.NONE) {
            continue;
        }
        const transition: f32 = (g_timer.getTime() - item.shoot_time) / (item.arrived_time - item.shoot_time);
        if (transition >= 1.0) {
            item.*.typ = ProjectileType.NONE;
            const idx: ?usize = Enemys.tryResolveEnemyId(item.target_enemy);
            if (idx) |i| {
                Enemys.addDamage(i, item.damage);
            }
            continue;
        }
    }
}

pub fn tryAdd(typ: ProjectileType, e_id: usize, pos: Vec2f, target: Vec2f, speed: f32, damage: f32) void {
    if (num_items >= MAX_PROJECTILES) {
        return;
    }
    for (0..MAX_PROJECTILES) |i| {
        if (items[i].typ == ProjectileType.NONE) {
            items[i].typ = typ;
            items[i].shoot_time = g_timer.getTime();
            items[i].arrived_time = g_timer.getTime() + Vec2f.distance(pos, target) / speed;
            items[i].damage = damage;
            items[i].pos = pos;
            items[i].target = target;
            items[i].direction_norm = Vec2f.normalize(Vec2f.sub(target, pos));
            items[i].target_enemy = Enemys.getEnemyId(e_id);
            if (num_items <= i) {
                num_items = i + 1;
            }
            return;
        }
    }
}
