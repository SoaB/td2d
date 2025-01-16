const std = @import("std");
const math = std.math;

pub fn Vector2(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn new(x: T, y: T) Self {
            return Self{
                .x = x,
                .y = y,
            };
        }
        pub fn zero() Self {
            return Self{
                .x = 0,
                .y = 0,
            };
        }
        pub fn one() Self {
            return Self{
                .x = 1,
                .y = 1,
            };
        }
        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
            };
        }
        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
            };
        }
        pub fn mul(a: Self, b: Self) Self {
            return Self{
                .x = a.x * b.x,
                .y = a.y * b.y,
            };
        }

        pub fn div(a: Self, b: Self) Self {
            return Self{
                .x = a.x / b.x,
                .y = a.y / b.y,
            };
        }

        pub fn len(a: Self) T {
            return @sqrt(a.x * a.x + a.y * a.y);
        }

        pub fn lenSquare(a: Self) T {
            return a.x * a.x + a.y * a.y;
        }

        pub fn normalize(a: Self) Self {
            const l = a.len();
            return Self{
                .x = a.x / l,
                .y = a.y / l,
            };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y;
        }

        pub fn cross(a: Self, b: Self) T {
            return a.x * b.y - a.y * b.x;
        }

        pub fn angle(a: Self) T {
            return math.atan2(f32, a.y, a.x);
        }

        pub fn scale(a: Self, scalar: T) Self {
            return Self{
                .x = a.x * scalar,
                .y = a.y * scalar,
            };
        }

        pub fn distance(v1: Self, v2: Self) T {
            const result: f32 = @sqrt((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y));
            return result;
        }
        pub fn distanceSquared(v1: Self, v2: Self) T {
            const result: f32 = (v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y);
            return result;
        }
        pub fn lerp(v1: Self, v2: Self, amount: T) Self {
            const x: T = v1.x + amount * (v2.x - v1.x);
            const y: T = v1.y + amount * (v2.y - v1.y);
            return Self{
                .x = x,
                .y = y,
            };
        }
        pub fn inv_sqrt(f: anytype, iterations: usize) @TypeOf(f) {
            const x2: @TypeOf(f) = f * 0.5;
            const uType: type = switch (@TypeOf(f)) {
                f32 => u32,
                f64 => u64,
                f128 => u128,
                else => @compileError("Unexpected type " ++ @typeName(@TypeOf(f))),
            };
            const i: uType = @bitCast(f); // evil float bit hacking
            var y: @TypeOf(f) = switch (@TypeOf(f)) { // what the fuck?
                f32 => @bitCast(0x5F3759DF - (i >> 1)),
                f64 => @bitCast(0x5FE6EB50C7B537A9 - (i >> 1)),
                // brute force, wild guess, f128 magic number
                f128 => @bitCast(0x5FFE6B21300000000000000000000000 - (i >> 1)),
                else => @compileError("Unexpected type " ++ @typeName(@TypeOf(f))),
            };
            for (0..iterations) |_| y = y * (1.5 - (x2 * y * y));

            return y;
        }
        pub fn normal(a: Self) Self {
            const inv_mag = inv_sqrt(a.x * a.x + a.y * a.y, 2);
            return Self{
                .x = a.x * inv_mag,
                .y = a.y * inv_mag,
            };
        }
    };
}

pub const Vec2f = Vector2(f32);
