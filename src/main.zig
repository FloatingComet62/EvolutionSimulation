const std = @import("std");
const renderers = @import("renderer.zig");

const WIDTH: usize = 1280;
const HEIGHT: usize = 800;

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
        renderer.drawCircle(100, 100, 5.0, renderer.colorFromRGBA(255, 0, 0, 255));
    }
}
