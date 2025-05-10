const std = @import("std");
const renderers = @import("renderer.zig");

fn drawPoint(renderer: *renderers.Renderer, x: i32, y: i32) void {
    renderer.drawCircle(x, y, 5.0, renderers.Color{
        .r = 255,
        .g = 0,
        .b = 0,
        .a = 255,
    });
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const seed: u64 = @truncate(@as(u128, @bitCast(std.time.nanoTimestamp())));
    try stdout.print("Seed: {}\n", .{seed});
    var prng = std.Random.DefaultPrng.init(seed);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    // const allocator: std.mem.Allocator = gpa.allocator();

    try stdout.print("Test rand float: {}\n", .{prng.random().float(f64)});

    var target_renderer = renderers.TargetRenderer.init();
    var renderer = target_renderer.renderer();
    renderer.init();
    defer renderer.deinit();

    var frame: u32 = 0;

    while (renderer.keepAlive()) {
        frame += 1;
        renderer.beginDrawing();
        defer renderer.endDrawing();
        for (0..100) |_| {
            const x = prng.random().int(u32) % 800 + 200;
            const y = prng.random().int(u32) % 600 + 100;
            drawPoint(&renderer, @intCast(x), @intCast(y));
        }
    }
}
