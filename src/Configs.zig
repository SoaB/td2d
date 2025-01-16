pub const SCR_WIDTH = 800;
pub const SCR_HEIGHT = 600;
pub const FPS = 60;
pub const GRID_SIZE = 20;
pub const GRID_WIDTH = 20;
pub const GRID_HEIGHT = 20;
pub const BLOCK_SIZE = 20;
const board_x = (SCR_WIDTH - GRID_WIDTH * GRID_SIZE) / 2;
const board_y = (SCR_HEIGHT - GRID_HEIGHT * GRID_SIZE) / 2;

const Vec2f = @import("Vector2.zig").Vec2f;

pub inline fn grid2scr(pos: Vec2f) Vec2f {
    const x = board_x + pos.x * GRID_WIDTH;
    const y = board_y + pos.y * GRID_HEIGHT;
    return Vec2f{ .x = x, .y = y };
}
pub inline fn grid2scrCenter(pos: Vec2f) Vec2f {
    const x = board_x + pos.x * GRID_WIDTH + GRID_WIDTH / 2;
    const y = board_y + pos.y * GRID_HEIGHT + GRID_HEIGHT / 2;
    return Vec2f{ .x = x, .y = y };
}
