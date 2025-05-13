const std = @import("std");
const renderers = @import("renderer.zig");
const sim = @import("simulation.zig");
const SimulationError = sim.SimulationError;

pub fn handleError(err: anyerror) void {
    switch (err) {
        SimulationError.TooManyEntities => {
            std.debug.print("Too many entities\n", .{});
        },
        SimulationError.TooLittleEntities => {
            std.debug.print("Too little entities\n", .{});
        },
        SimulationError.OutOfMemory => {
            std.debug.print("Out of memory\n", .{});
        },
        else => unreachable,
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const seed: u64 = @truncate(@as(u128, @bitCast(std.time.nanoTimestamp())));
    try stdout.print("Seed: {}\n", .{seed});
    var prng = std.Random.DefaultPrng.init(seed);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator: std.mem.Allocator = gpa.allocator();

    var gene_allocator = std.heap.ArenaAllocator.init(allocator);
    defer gene_allocator.deinit();

    try stdout.print("Test rand float: {}\n", .{prng.random().float(f64)});

    var target_renderer = renderers.TargetRenderer.init();
    var renderer = target_renderer.renderer();
    renderer.init();
    defer renderer.deinit();

    var simulation = sim.Simulation.init(
        allocator,
        gene_allocator.allocator(),
        &prng,
        sim.SimulationConfig.default(),
    ) catch |err| {
        handleError(err);
        return;
    };
    defer simulation.deinit();

    for (0..100) |_| {
        const x: i32 = @intCast(prng.random().int(u32) % 1000 + 100);
        const y: i32 = @intCast(prng.random().int(u32) % 600 + 100);
        _ = simulation.add_entity(x, y, true) catch |err| {
            handleError(err);
            continue;
        };
    }

    var frame: u32 = 0;

    while (renderer.keepAlive()) {
        frame += 1;
        simulation.update(frame) catch |err| handleError(err);
        renderer.beginDrawing();
        defer renderer.endDrawing();
        for (simulation.entities.items) |entity| {
            entity.drawPoint(&renderer);
        }
    }
}
