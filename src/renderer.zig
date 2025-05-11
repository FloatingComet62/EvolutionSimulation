const std = @import("std");
pub const rl = @import("raylib");

pub const TargetRenderer = RaylibRenderer;

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
    pub fn init(r: u8, g: u8, b: u8, a: u8) Color {
        return Color{ .r = r, .g = g, .b = b, .a = a };
    }
    pub fn fromHex(hex: u32) Color {
        // 0xRRGGBBAA
        return Color{
            .r = @intCast((hex >> 24) & 0xFF),
            .g = @intCast((hex >> 16) & 0xFF),
            .b = @intCast((hex >> 8) & 0xFF),
            .a = @intCast(hex & 0xFF),
        };
    }
};

pub const Renderer = struct {
    const Self = @This();
    ptr: *anyopaque,
    initFn: *const fn (ptr: *anyopaque) void,
    deinitFn: *const fn (ptr: *anyopaque) void,
    keepAliveFn: *const fn (ptr: *anyopaque) bool,
    beginDrawingFn: *const fn (ptr: *anyopaque) void,
    endDrawingFn: *const fn (ptr: *anyopaque) void,
    drawCircleFn: *const fn (ptr: *anyopaque, x: i32, y: i32, radius: f32, color: Color) void,

    pub fn init(self: *const Self) void {
        self.initFn(self.ptr);
    }
    pub fn deinit(self: *const Self) void {
        self.deinitFn(self.ptr);
    }
    pub fn keepAlive(self: *const Self) bool {
        return self.keepAliveFn(self.ptr);
    }
    pub fn beginDrawing(self: *const Self) void {
        self.beginDrawingFn(self.ptr);
    }
    pub fn endDrawing(self: *const Self) void {
        self.endDrawingFn(self.ptr);
    }
    pub fn drawCircle(self: *const Self, x: i32, y: i32, radius: f32, color: Color) void {
        self.drawCircleFn(self.ptr, x, y, radius, color);
    }
};

pub const RaylibRenderer = struct {
    const Self = @This();

    // Implement these for custom renderer, and then change the TargetRenderer global variable
    pub fn init() Self {
        return .{};
    }
    pub fn renderer(self: *Self) Renderer {
        return .{
            .ptr = self,
            .initFn = renderer_init,
            .deinitFn = renderer_deinit,
            .keepAliveFn = keepAlive,
            .beginDrawingFn = beginDrawing,
            .endDrawingFn = endDrawing,
            .drawCircleFn = drawCircle,
        };
    }
    // ---------------------------

    pub fn renderer_init(_: *const anyopaque) void {
        rl.setConfigFlags(rl.ConfigFlags{ .vsync_hint = true });
        rl.initWindow(1200, 800, "Evolution");
        const windowIcon = rl.loadImage("favicon.png");
        if (windowIcon) |icon| {
            rl.setWindowIcon(icon);
            rl.unloadImage(icon);
        } else |err| {
            std.debug.print("Failed to load window icon {}\n", .{err});
        }
    }
    pub fn renderer_deinit(_: *const anyopaque) void {
        rl.closeWindow();
    }

    pub fn keepAlive(_: *const anyopaque) bool {
        std.debug.assert(rl.isWindowReady());
        return !rl.windowShouldClose();
    }
    pub fn beginDrawing(_: *const anyopaque) void {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
    }
    pub fn endDrawing(_: *const anyopaque) void {
        rl.endDrawing();
        rl.setMouseCursor(rl.MouseCursor.default);
    }
    pub fn drawCircle(_: *const anyopaque, x: i32, y: i32, radius: f32, color: Color) void {
        const c = rl.Color{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        };
        rl.drawCircle(x, y, radius, c);
    }
};
