const std = @import("std");
pub const rl = @import("raylib");

pub const TargetRenderer = RaylibRenderer;

pub const Renderer = struct {
    const Self = @This();
    ptr: *anyopaque,
    initFn: *const fn (ptr: *anyopaque) void,
    deinitFn: *const fn (ptr: *anyopaque) void,
    keepAliveFn: *const fn (ptr: *anyopaque) bool,
    beginDrawingFn: *const fn (ptr: *anyopaque) void,
    endDrawingFn: *const fn (ptr: *anyopaque) void,
    drawCircleFn: *const fn (ptr: *anyopaque, x: i32, y: i32, radius: f32, color: rl.Color) void,
    colorFromRGBAFn: *const fn (r: u8, g: u8, b: u8, a: u8) rl.Color,

    pub fn init(self: *Self) void {
        self.initFn(self.ptr);
    }
    pub fn deinit(self: *Self) void {
        self.deinitFn(self.ptr);
    }

    pub fn keepAlive(self: *Self) bool {
        return self.keepAliveFn(self.ptr);
    }

    pub fn beginDrawing(self: *Self) void {
        self.beginDrawingFn(self.ptr);
    }

    pub fn endDrawing(self: *Self) void {
        self.endDrawingFn(self.ptr);
    }

    pub fn colorFromRGBA(self: *Self, r: u8, g: u8, b: u8, a: u8) rl.Color {
        return self.colorFromRGBAFn(r, g, b, a);
    }

    pub fn drawCircle(self: *Self, x: i32, y: i32, radius: f32, color: rl.Color) void {
        self.drawCircleFn(self.ptr, x, y, radius, color);
    }
};

pub const RaylibRenderer = struct {
    const Self = @This();

    pub fn init() Self {
        return .{};
    }
    pub fn renderer_init(_: *anyopaque) void {
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
    pub fn renderer_deinit(_: *anyopaque) void {
        rl.closeWindow();
    }

    pub fn keepAlive(_: *anyopaque) bool {
        std.debug.assert(rl.isWindowReady());
        return !rl.windowShouldClose();
    }

    pub fn beginDrawing(_: *anyopaque) void {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
    }

    pub fn endDrawing(_: *anyopaque) void {
        rl.endDrawing();
        rl.setMouseCursor(rl.MouseCursor.default);
    }

    pub fn drawCircle(_: *anyopaque, x: i32, y: i32, radius: f32, color: rl.Color) void {
        rl.drawCircle(x, y, radius, color);
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
            .colorFromRGBAFn = rl.Color.init,
        };
    }
};
