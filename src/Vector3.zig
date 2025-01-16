const std = @import("std");
const math = std.math;
const Matrix = @import("Math3D.zig").Matrix;
pub fn Vector3(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
        pub fn new(x: T, y: T, z: T) Self {
            return Self{
                .x = x,
                .y = y,
                .z = z,
            };
        }
        pub fn zero() Self {
            return Self{
                .x = 0,
                .y = 0,
                .z = 0,
            };
        }
        pub fn one() Self {
            return Self{
                .x = 1,
                .y = 1,
                .z = 1,
            };
        }
        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
                .z = a.z + b.z,
            };
        }
        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
            };
        }
        pub fn mul(a: Self, b: Self) Self {
            return Self{
                .x = a.x * b.x,
                .y = a.y * b.y,
                .z = a.z * b.z,
            };
        }

        pub fn div(a: Self, b: Self) Self {
            return Self{
                .x = a.x / b.x,
                .y = a.y / b.y,
                .z = a.z / b.z,
            };
        }

        pub fn len(a: Self) T {
            return @sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
        }

        pub fn lenSquare(a: Self) T {
            return a.x * a.x + a.y * a.y + a.z * a.z;
        }

        pub fn normalize(a: Self) Self {
            const l = a.len();
            return Self{
                .x = a.x / l,
                .y = a.y / l,
                .z = a.z / l,
            };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn cross(a: Self, b: Self) T {
            return a.x * b.y - a.y * b.x + a.z * b.z;
        }

        pub fn angle(a: Self) T {
            return math.atan2(f32, a.y, a.x, a.z);
        }

        pub fn scale(a: Self, scalar: T) Self {
            return Self{
                .x = a.x * scalar,
                .y = a.y * scalar,
                .z = a.z * scalar,
            };
        }

        pub fn distance(v1: Self, v2: Self) T {
            const result: f32 = @sqrt((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y) + (v1.z - v2.z) * (v1.z - v2.z));
            return result;
        }
        pub fn distanceSquared(v1: Self, v2: Self) T {
            const result: f32 = (v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y) + (v1.z - v2.z) * (v1.z - v2.z);
            return result;
        }
        pub fn lerp(v1: Self, v2: Self, amount: T) Self {
            const x: T = v1.x + amount * (v2.x - v1.x);
            const y: T = v1.y + amount * (v2.y - v1.y);
            const z: T = v1.z + amount * (v2.z - v1.z);
            return Self{
                .x = x,
                .y = y,
                .z = z,
            };
        }
        // Transforms a Vec3f by a given Matrix
        pub fn transform(v: Self, mat: Matrix) Self {
            const x: f32 = v.x;
            const y: f32 = v.y;
            const z: f32 = v.z;
            const result: Self = Self{
                .x = mat.m0 * x + mat.m4 * y + mat.m8 * z + mat.m12,
                .y = mat.m1 * x + mat.m5 * y + mat.m9 * z + mat.m13,
                .z = mat.m2 * x + mat.m6 * y + mat.m10 * z + mat.m14,
            };

            return result;
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
            const inv_mag = inv_sqrt(a.x * a.x + a.y * a.y + a.z * a.z, 2);
            return Self{
                .x = a.x * inv_mag,
                .y = a.y * inv_mag,
                .z = a.z * inv_mag,
            };
        }
    };
}

pub const Vec3f = Vector3(f32);
