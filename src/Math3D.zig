const Vec3f = @import("Vector3.zig").Vec3f;

pub const Matrix = struct {
    m0: f32,
    m4: f32,
    m8: f32,
    m12: f32, // Matrix first row (4 components)
    m1: f32,
    m5: f32,
    m9: f32,
    m13: f32, // Matrix second row (4 components)
    m2: f32,
    m6: f32,
    m10: f32,
    m14: f32, // Matrix third row (4 components)
    m3: f32,
    m7: f32,
    m11: f32,
    m15: f32, // Matrix fourth row (4 components)
};

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant
pub fn determinant(mat: Matrix) f32 {
    // Cache the matrix values (speed optimization)
    const a00 = mat.m0;
    const a01 = mat.m1;
    const a02 = mat.m2;
    const a03 = mat.m3;
    const a10 = mat.m4;
    const a11 = mat.m5;
    const a12 = mat.m6;
    const a13 = mat.m7;
    const a20 = mat.m8;
    const a21 = mat.m9;
    const a22 = mat.m10;
    const a23 = mat.m11;
    const a30 = mat.m12;
    const a31 = mat.m13;
    const a32 = mat.m14;
    const a33 = mat.m15;

    const result = a30 * a21 * a12 * a03 - a20 * a31 * a12 * a03 - a30 * a11 * a22 * a03 + a10 * a31 * a22 * a03 +
        a20 * a11 * a32 * a03 - a10 * a21 * a32 * a03 - a30 * a21 * a02 * a13 + a20 * a31 * a02 * a13 +
        a30 * a01 * a22 * a13 - a00 * a31 * a22 * a13 - a20 * a01 * a32 * a13 + a00 * a21 * a32 * a13 +
        a30 * a11 * a02 * a23 - a10 * a31 * a02 * a23 - a30 * a01 * a12 * a23 + a00 * a31 * a12 * a23 +
        a10 * a01 * a32 * a23 - a00 * a11 * a32 * a23 - a20 * a11 * a02 * a33 + a10 * a21 * a02 * a33 +
        a20 * a01 * a12 * a33 - a00 * a21 * a12 * a33 - a10 * a01 * a22 * a33 + a00 * a11 * a22 * a33;

    return result;
}

// Get the trace of the matrix (sum of the values along the diagonal)
pub fn trace(mat: Matrix) f32 {
    const result: f32 = (mat.m0 + mat.m5 + mat.m10 + mat.m15);
    return result;
}

// Transposes provided matrix
pub fn transpose(mat: Matrix) Matrix {
    var result: Matrix = {};

    result.m0 = mat.m0;
    result.m1 = mat.m4;
    result.m2 = mat.m8;
    result.m3 = mat.m12;
    result.m4 = mat.m1;
    result.m5 = mat.m5;
    result.m6 = mat.m9;
    result.m7 = mat.m13;
    result.m8 = mat.m2;
    result.m9 = mat.m6;
    result.m10 = mat.m10;
    result.m11 = mat.m14;
    result.m12 = mat.m3;
    result.m13 = mat.m7;
    result.m14 = mat.m11;
    result.m15 = mat.m15;

    return result;
}

// Invert provided matrix
pub fn invert(mat: Matrix) Matrix {
    var result: Matrix = undefined;
    // Cache the matrix values (speed optimization)
    const a00 = mat.m0;
    const a01 = mat.m1;
    const a02 = mat.m2;
    const a03 = mat.m3;
    const a10 = mat.m4;
    const a11 = mat.m5;
    const a12 = mat.m6;
    const a13 = mat.m7;
    const a20 = mat.m8;
    const a21 = mat.m9;
    const a22 = mat.m10;
    const a23 = mat.m11;
    const a30 = mat.m12;
    const a31 = mat.m13;
    const a32 = mat.m14;
    const a33 = mat.m15;

    const b00 = a00 * a11 - a01 * a10;
    const b01 = a00 * a12 - a02 * a10;
    const b02 = a00 * a13 - a03 * a10;
    const b03 = a01 * a12 - a02 * a11;
    const b04 = a01 * a13 - a03 * a11;
    const b05 = a02 * a13 - a03 * a12;
    const b06 = a20 * a31 - a21 * a30;
    const b07 = a20 * a32 - a22 * a30;
    const b08 = a20 * a33 - a23 * a30;
    const b09 = a21 * a32 - a22 * a31;
    const b10 = a21 * a33 - a23 * a31;
    const b11 = a22 * a33 - a23 * a32;

    // Calculate the invert determinant (inlined to avoid double-caching)
    const invDet = 1.0 / (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06);

    result.m0 = (a11 * b11 - a12 * b10 + a13 * b09) * invDet;
    result.m1 = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet;
    result.m2 = (a31 * b05 - a32 * b04 + a33 * b03) * invDet;
    result.m3 = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet;
    result.m4 = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet;
    result.m5 = (a00 * b11 - a02 * b08 + a03 * b07) * invDet;
    result.m6 = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet;
    result.m7 = (a20 * b05 - a22 * b02 + a23 * b01) * invDet;
    result.m8 = (a10 * b10 - a11 * b08 + a13 * b06) * invDet;
    result.m9 = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet;
    result.m10 = (a30 * b04 - a31 * b02 + a33 * b00) * invDet;
    result.m11 = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet;
    result.m12 = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet;
    result.m13 = (a00 * b09 - a01 * b07 + a02 * b06) * invDet;
    result.m14 = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet;
    result.m15 = (a20 * b03 - a21 * b01 + a22 * b00) * invDet;

    return result;
}

// Get identity matrix
pub fn identity() Matrix {
    const result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    return result;
}

// Add two matrices
pub fn add(left: Matrix, right: Matrix) Matrix {
    var result: Matrix = {};

    result.m0 = left.m0 + right.m0;
    result.m1 = left.m1 + right.m1;
    result.m2 = left.m2 + right.m2;
    result.m3 = left.m3 + right.m3;
    result.m4 = left.m4 + right.m4;
    result.m5 = left.m5 + right.m5;
    result.m6 = left.m6 + right.m6;
    result.m7 = left.m7 + right.m7;
    result.m8 = left.m8 + right.m8;
    result.m9 = left.m9 + right.m9;
    result.m10 = left.m10 + right.m10;
    result.m11 = left.m11 + right.m11;
    result.m12 = left.m12 + right.m12;
    result.m13 = left.m13 + right.m13;
    result.m14 = left.m14 + right.m14;
    result.m15 = left.m15 + right.m15;

    return result;
}

// Subtract two matrices (left - right)
pub fn subtract(left: Matrix, right: Matrix) Matrix {
    var result: Matrix = {};

    result.m0 = left.m0 - right.m0;
    result.m1 = left.m1 - right.m1;
    result.m2 = left.m2 - right.m2;
    result.m3 = left.m3 - right.m3;
    result.m4 = left.m4 - right.m4;
    result.m5 = left.m5 - right.m5;
    result.m6 = left.m6 - right.m6;
    result.m7 = left.m7 - right.m7;
    result.m8 = left.m8 - right.m8;
    result.m9 = left.m9 - right.m9;
    result.m10 = left.m10 - right.m10;
    result.m11 = left.m11 - right.m11;
    result.m12 = left.m12 - right.m12;
    result.m13 = left.m13 - right.m13;
    result.m14 = left.m14 - right.m14;
    result.m15 = left.m15 - right.m15;

    return result;
}

// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!
pub fn multiply(left: Matrix, right: Matrix) Matrix {
    var result: Matrix = undefined;

    result.m0 = left.m0 * right.m0 + left.m1 * right.m4 + left.m2 * right.m8 + left.m3 * right.m12;
    result.m1 = left.m0 * right.m1 + left.m1 * right.m5 + left.m2 * right.m9 + left.m3 * right.m13;
    result.m2 = left.m0 * right.m2 + left.m1 * right.m6 + left.m2 * right.m10 + left.m3 * right.m14;
    result.m3 = left.m0 * right.m3 + left.m1 * right.m7 + left.m2 * right.m11 + left.m3 * right.m15;
    result.m4 = left.m4 * right.m0 + left.m5 * right.m4 + left.m6 * right.m8 + left.m7 * right.m12;
    result.m5 = left.m4 * right.m1 + left.m5 * right.m5 + left.m6 * right.m9 + left.m7 * right.m13;
    result.m6 = left.m4 * right.m2 + left.m5 * right.m6 + left.m6 * right.m10 + left.m7 * right.m14;
    result.m7 = left.m4 * right.m3 + left.m5 * right.m7 + left.m6 * right.m11 + left.m7 * right.m15;
    result.m8 = left.m8 * right.m0 + left.m9 * right.m4 + left.m10 * right.m8 + left.m11 * right.m12;
    result.m9 = left.m8 * right.m1 + left.m9 * right.m5 + left.m10 * right.m9 + left.m11 * right.m13;
    result.m10 = left.m8 * right.m2 + left.m9 * right.m6 + left.m10 * right.m10 + left.m11 * right.m14;
    result.m11 = left.m8 * right.m3 + left.m9 * right.m7 + left.m10 * right.m11 + left.m11 * right.m15;
    result.m12 = left.m12 * right.m0 + left.m13 * right.m4 + left.m14 * right.m8 + left.m15 * right.m12;
    result.m13 = left.m12 * right.m1 + left.m13 * right.m5 + left.m14 * right.m9 + left.m15 * right.m13;
    result.m14 = left.m12 * right.m2 + left.m13 * right.m6 + left.m14 * right.m10 + left.m15 * right.m14;
    result.m15 = left.m12 * right.m3 + left.m13 * right.m7 + left.m14 * right.m11 + left.m15 * right.m15;

    return result;
}

// Get translation matrix
pub fn translate(x: f32, y: f32, z: f32) Matrix {
    const result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = x,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = y,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = z,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };
    return result;
}

// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians
pub fn rotate(ax: f32, ay: f32, az: f32, angle: f32) Matrix {
    var result: Matrix = {};
    var x: f32 = ax;
    var y: f32 = ay;
    var z: f32 = az;
    const lengthSquared: f32 = x * x + y * y + z * z;
    if ((lengthSquared != 1.0) and (lengthSquared != 0.0)) {
        const ilength: f32 = 1.0 / @sqrt(lengthSquared);
        x *= ilength;
        y *= ilength;
        z *= ilength;
    }
    const sinres: f32 = @sin(angle);
    const cosres: f32 = @cos(angle);
    const t = 1.0 - cosres;

    result.m0 = x * x * t + cosres;
    result.m1 = y * x * t + z * sinres;
    result.m2 = z * x * t - y * sinres;
    result.m3 = 0.0;

    result.m4 = x * y * t - z * sinres;
    result.m5 = y * y * t + cosres;
    result.m6 = z * y * t + x * sinres;
    result.m7 = 0.0;

    result.m8 = x * z * t + y * sinres;
    result.m9 = y * z * t - x * sinres;
    result.m10 = z * z * t + cosres;
    result.m11 = 0.0;

    result.m12 = 0.0;
    result.m13 = 0.0;
    result.m14 = 0.0;
    result.m15 = 1.0;

    return result;
}

// Get x-rotation matrix
// NOTE: Angle must be provided in radians
pub fn rotateX(angle: f32) Matrix {
    var result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    const cosres: f32 = @cos(angle);
    const sinres: f32 = @sin(angle);

    result.m5 = cosres;
    result.m6 = sinres;
    result.m9 = -sinres;
    result.m10 = cosres;

    return result;
}

// Get y-rotation matrix
// NOTE: Angle must be provided in radians
pub fn rotateY(angle: f32) Matrix {
    var result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    const cosres: f32 = @cos(angle);
    const sinres: f32 = @sin(angle);

    result.m0 = cosres;
    result.m2 = -sinres;
    result.m8 = sinres;
    result.m10 = cosres;

    return result;
}

// Get z-rotation matrix
// NOTE: Angle must be provided in radians
pub fn rotateZ(angle: f32) Matrix {
    var result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    const cosres: f32 = @cos(angle);
    const sinres: f32 = @sin(angle);

    result.m0 = cosres;
    result.m1 = sinres;
    result.m4 = -sinres;
    result.m5 = cosres;

    return result;
}

// Get xyz-rotation matrix
// NOTE: Angle must be provided in radians
pub fn rotateXYZ(x: f32, y: f32, z: f32) Matrix {
    var result: Matrix = Matrix{
        .m0 = 1.0,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = 1.0,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = 1.0,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    const cosz: f32 = @cos(z);
    const sinz: f32 = @sin(z);
    const cosy: f32 = @cos(y);
    const siny: f32 = @sin(y);
    const cosx: f32 = @cos(x);
    const sinx: f32 = @sin(x);

    result.m0 = cosz * cosy;
    result.m1 = (cosz * siny * sinx) - (sinz * cosx);
    result.m2 = (cosz * siny * cosx) + (sinz * sinx);

    result.m4 = sinz * cosy;
    result.m5 = (sinz * siny * sinx) + (cosz * cosx);
    result.m6 = (sinz * siny * cosx) - (cosz * sinx);

    result.m8 = -siny;
    result.m9 = cosy * sinx;
    result.m10 = cosy * cosx;

    return result;
}

// Get zyx-rotation matrix
// NOTE: Angle must be provided in radians
pub fn rotateZYX(x: f32, y: f32, z: f32) Matrix {
    var result: Matrix = {};

    const cz: f32 = @cos(z);
    const sz: f32 = @sin(z);
    const cy: f32 = @cos(y);
    const sy: f32 = @sin(y);
    const cx: f32 = @cos(x);
    const sx: f32 = @sin(x);

    result.m0 = cz * cy;
    result.m4 = cz * sy * sx - cx * sz;
    result.m8 = sz * sx + cz * cx * sy;
    result.m12 = 0;

    result.m1 = cy * sz;
    result.m5 = cz * cx + sz * sy * sx;
    result.m9 = cx * sz * sy - cz * sx;
    result.m13 = 0;

    result.m2 = -sy;
    result.m6 = cy * sx;
    result.m10 = cy * cx;
    result.m14 = 0;

    result.m3 = 0;
    result.m7 = 0;
    result.m11 = 0;
    result.m15 = 1;

    return result;
}

// Get scaling matrix
pub fn scale(x: f32, y: f32, z: f32) Matrix {
    const result: Matrix = Matrix{
        .m0 = x,
        .m4 = 0.0,
        .m8 = 0.0,
        .m12 = 0.0,
        .m1 = 0.0,
        .m5 = y,
        .m9 = 0.0,
        .m13 = 0.0,
        .m2 = 0.0,
        .m6 = 0.0,
        .m10 = z,
        .m14 = 0.0,
        .m3 = 0.0,
        .m7 = 0.0,
        .m11 = 0.0,
        .m15 = 1.0,
    };

    return result;
}

// Get perspective projection matrix
pub fn frustum(left: f32, right: f32, bottom: f32, top: f32, nearPlane: f32, farPlane: f32) Matrix {
    var result: Matrix = {};

    const rl = right - left;
    const tb = top - bottom;
    const f_n = farPlane - nearPlane;

    result.m0 = (nearPlane * 2.0) / rl;
    result.m1 = 0.0;
    result.m2 = 0.0;
    result.m3 = 0.0;

    result.m4 = 0.0;
    result.m5 = (nearPlane * 2.0) / tb;
    result.m6 = 0.0;
    result.m7 = 0.0;

    result.m8 = (right + left) / rl;
    result.m9 = (top + bottom) / tb;
    result.m10 = -(farPlane + nearPlane) / f_n;
    result.m11 = -1.0;

    result.m12 = 0.0;
    result.m13 = 0.0;
    result.m14 = -(farPlane * nearPlane * 2.0) / f_n;
    result.m15 = 0.0;

    return result;
}

// Get perspective projection matrix
// NOTE: Fovy angle must be provided in radians
pub fn perspective(fovY: f32, aspect: f32, nearPlane: f32, farPlane: f32) Matrix {
    var result: Matrix = {};

    const top = nearPlane * @tan(fovY * 0.5);
    const bottom = -top;
    const right = top * aspect;
    const left = -right;

    // MatrixFrustum(-right, right, -top, top, near, far);
    const rl = right - left;
    const tb = top - bottom;
    const f_n = farPlane - nearPlane;

    result.m0 = (nearPlane * 2.0) / rl;
    result.m5 = (nearPlane * 2.0) / tb;
    result.m8 = (right + left) / rl;
    result.m9 = (top + bottom) / tb;
    result.m10 = -(farPlane + nearPlane) / f_n;
    result.m11 = -1.0;
    result.m14 = -(farPlane * nearPlane * 2.0) / f_n;

    return result;
}

// Get orthographic projection matrix
pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, nearPlane: f32, farPlane: f32) Matrix {
    var result: Matrix = {};

    const rl = (right - left);
    const tb = (top - bottom);
    const f_n = (farPlane - nearPlane);

    result.m0 = 2.0 / rl;
    result.m1 = 0.0;
    result.m2 = 0.0;
    result.m3 = 0.0;
    result.m4 = 0.0;
    result.m5 = 2.0 / tb;
    result.m6 = 0.0;
    result.m7 = 0.0;
    result.m8 = 0.0;
    result.m9 = 0.0;
    result.m10 = -2.0 / f_n;
    result.m11 = 0.0;
    result.m12 = -(left + right) / rl;
    result.m13 = -(top + bottom) / tb;
    result.m14 = -(farPlane + nearPlane) / f_n;
    result.m15 = 1.0;

    return result;
}

// Get camera look-at matrix (view matrix)
pub fn lookAt(eye: Vec3f, target: Vec3f, up: Vec3f) Matrix {
    var result = {};
    // Vector3Subtract(eye, target)
    // Vector3Normalize(vz)
    const vz: Vec3f = Vec3f.normalize(Vec3f.sub(eye, target));
    // Vector3CrossProduct(up, vz)
    // Vector3Normalize(x)
    const vx: Vec3f = Vec3f.normalize(Vec3f.crossProduct(up, vz));
    // Vector3CrossProduct(vz, vx)
    const vy: Vec3f = Vec3f.crossProduct(vz, vx);

    result.m0 = vx.x;
    result.m1 = vy.x;
    result.m2 = vz.x;
    result.m3 = 0.0;
    result.m4 = vx.y;
    result.m5 = vy.y;
    result.m6 = vz.y;
    result.m7 = 0.0;
    result.m8 = vx.z;
    result.m9 = vy.z;
    result.m10 = vz.z;
    result.m11 = 0.0;
    result.m12 = -(vx.x * eye.x + vx.y * eye.y + vx.z * eye.z); // Vector3DotProduct(vx, eye)
    result.m13 = -(vy.x * eye.x + vy.y * eye.y + vy.z * eye.z); // Vector3DotProduct(vy, eye)
    result.m14 = -(vz.x * eye.x + vz.y * eye.y + vz.z * eye.z); // Vector3DotProduct(vz, eye)
    result.m15 = 1.0;

    return result;
}

// Get float array of matrix data
pub fn toFloatV(mat: Matrix) [16]f32 {
    var result: [16]f32 = undefined;
    result[0] = mat.m0;
    result[1] = mat.m1;
    result[2] = mat.m2;
    result[3] = mat.m3;
    result[4] = mat.m4;
    result[5] = mat.m5;
    result[6] = mat.m6;
    result[7] = mat.m7;
    result[8] = mat.m8;
    result[9] = mat.m9;
    result[10] = mat.m10;
    result[11] = mat.m11;
    result[12] = mat.m12;
    result[13] = mat.m13;
    result[14] = mat.m14;
    result[15] = mat.m15;
    return result;
}
