const rl = @cImport({
    @cDefine("SUPPORT_GIF_RECORDING", "1");
    @cInclude("Raylib.h");
});

const std = @import("std");
const math = std.math;
const print = std.debug.print;

const Vec2f = @import("Vector2.zig").Vec2f;
const g_timer = @import("GameTimer.zig");
const g_configs = @import("Configs.zig");
const scr_w = g_configs.SCR_WIDTH;
const scr_h = g_configs.SCR_HEIGHT;
// Towers module
const Towers = @import("Towers.zig");
const TowerType = Towers.TowerType;
// Enemy module
const Enemys = @import("Enemys.zig");
const EnemyType = Enemys.EnemyType;
// Projectiles module
const Projectiles = @import("Projectiles.zig");
const ProjectileType = Projectiles.ProjectileType;

pub fn drawGrid() void {
    const grid_size: usize = g_configs.GRID_SIZE;
    const grid_color = rl.Color{ .r = 100, .g = 100, .b = 100, .a = 255 };
    for (0..grid_size) |y| {
        for (0..grid_size) |x| {
            const x_pos: i32 = @intCast(x * g_configs.BLOCK_SIZE + (g_configs.SCR_WIDTH - g_configs.BLOCK_SIZE * grid_size) / 2);
            const y_pos: i32 = @intCast(y * g_configs.BLOCK_SIZE + (g_configs.SCR_HEIGHT - g_configs.BLOCK_SIZE * grid_size) / 2);
            rl.DrawRectangle(x_pos, y_pos, g_configs.BLOCK_SIZE, g_configs.BLOCK_SIZE, grid_color);
            rl.DrawRectangleLines(x_pos, y_pos, g_configs.BLOCK_SIZE, g_configs.BLOCK_SIZE, rl.WHITE);
        }
    }
}
pub fn init() void {
    g_timer.init();
    Towers.init();
    Enemys.init();
    Projectiles.init();
    Enemys.tryAdd(Vec2f.new(19, 19), EnemyType.MIMION);
    Towers.tryAdd(Vec2f.new(10, 10), TowerType.BASE);
    Towers.tryAdd(Vec2f.new(11, 11), TowerType.GUN);
    Towers.tryAdd(Vec2f.new(9, 9), TowerType.GUN);
}
pub fn deinit() void {}
var next_spawn_time: f32 = 0;
pub fn update() void {
    g_timer.update(rl.GetFrameTime());
    Enemys.update();
    Towers.update();
    Projectiles.update();
    if (g_timer.getTime() > next_spawn_time and Enemys.getEnemyCount() < 50) {
        next_spawn_time = g_timer.getTime() + 0.5;
        Enemys.spawn(EnemyType.MIMION);
    }
}
pub fn drawText(text: []const u8, x: i32, y: i32, size: i32, color: rl.Color) void {
    const textWidth: i32 = rl.MeasureText(text.ptr, size);
    rl.DrawText(text.ptr, x - @divExact(textWidth, 2), y, size, color);
}
pub fn draw() void {
    const str = "Tower Defense...";
    drawText(str, 400, 520, 20, rl.WHITE);
    const time: f32 = g_timer.getTime();
    var buf: [32]u8 = undefined;
    const time_str = std.fmt.bufPrint(buf[0..], "Time: {d:4.4} s", .{time}) catch unreachable;
    drawText(time_str, 400, 500, 20, rl.WHITE);
    Towers.draw();
    Enemys.draw();
    Projectiles.draw();
}
pub fn main() !void {
    //    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //    const allocator = gpa.allocator();
    rl.SetTraceLogLevel(rl.LOG_ERROR);
    rl.InitWindow(scr_w, scr_h, "Tower Defense");
    rl.SetTargetFPS(60);
    init();
    while (!rl.WindowShouldClose()) {
        update();
        rl.BeginDrawing();
        rl.ClearBackground(rl.BLACK);
        drawGrid();
        draw();
        rl.EndDrawing();
    }
    rl.CloseWindow();
    //    _ = gpa.deinit();
}
