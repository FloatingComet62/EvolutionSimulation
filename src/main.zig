const std = @import("std");
const renderers = @import("renderer.zig");
const sim = @import("simulation.zig");

fn drawPoint(renderer: *renderers.Renderer, x: i32, y: i32) void {
    renderer.drawCircle(
        x,
        y,
        5.0,
        renderers.Color.fromHex(0xFF00FFFF),
    );
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const seed: u64 = @truncate(@as(u128, @bitCast(std.time.nanoTimestamp())));
    try stdout.print("Seed: {}\n", .{seed});
    var prng = std.Random.DefaultPrng.init(seed);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator: std.mem.Allocator = gpa.allocator();

    try stdout.print("Test rand float: {}\n", .{prng.random().float(f64)});

    var target_renderer = renderers.TargetRenderer.init();
    var renderer = target_renderer.renderer();
    renderer.init();
    defer renderer.deinit();

    var simulation = sim.Simulation.init(allocator, &prng);
    defer simulation.deinit();

    for (0..1000) |_| {
        const x: i32 = @intCast(prng.random().int(u32) % 1000 + 100);
        const y: i32 = @intCast(prng.random().int(u32) % 600 + 100);
        try simulation.add_entity(x, y);
    }

    var frame: u32 = 0;

    while (renderer.keepAlive()) {
        frame += 1;
        simulation.update();

        renderer.beginDrawing();
        defer renderer.endDrawing();
        for (simulation.entities.items) |entity| {
            drawPoint(&renderer, entity.x, entity.y);
        }
    }
}
