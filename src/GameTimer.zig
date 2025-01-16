const std = @import("std");

const GameTime = struct {
    time: f32,
    delta_time: f32,
};
var game_timer: GameTime = undefined;

pub fn init() void {
    game_timer.time = 0.0;
    game_timer.delta_time = 0.0;
}

pub fn update(delta_time: f32) void {
    game_timer.time += delta_time;
    game_timer.delta_time = delta_time;
}

pub fn reset() void {
    game_timer.time = 0.0;
    game_timer.delta_time = 0.0;
}

pub fn getTime() f32 {
    return game_timer.time;
}
pub fn getDeltaTime() f32 {
    return game_timer.delta_time;
}
