const std = @import("std");
const renderers = @import("../renderer.zig");
const SimulationError = @import("error.zig").SimulationError;
const EntityConfig = @import("config.zig").EntityConfig;

pub const Entity = struct {
    const Self = @This();
    id: u32,
    x: i32,
    y: i32,
    genes: std.ArrayList(f64),
    config: EntityConfig,

    pub fn init(allocator: std.mem.Allocator, config: EntityConfig, id: u32, x: i32, y: i32) SimulationError!Self {
        var genes = try std.ArrayList(f64).initCapacity(
            allocator,
            config.genes_length,
        );
        for (0..100) |_| {
            genes.appendAssumeCapacity(0);
        }
        const self = Self{
            .id = id,
            .x = x,
            .y = y,
            .genes = genes,
            .config = config,
        };
        return self;
    }
    pub fn drawPoint(self: *const Self, renderer: *renderers.Renderer) void {
        renderer.drawCircle(
            self.x,
            self.y,
            5.0,
            renderers.Color.init(
                self.getRedFromVariance(self.gene_variance()),
                0,
                255,
                255,
            ),
        );
    }
    pub fn randomize(self: *Self, prng: *std.Random.Xoshiro256) void {
        for (0..self.genes.items.len) |i| {
            self.genes.items[i] = prng.random().float(f64) * 150;
        }
    }
    pub fn gene_mean(self: *const Self) f64 {
        var sum: f64 = 0;
        for (0..self.genes.items.len) |i| {
            sum += self.genes.items[i];
        }
        return sum / @as(f64, @floatFromInt(self.genes.items.len));
    }
    pub fn gene_variance(self: *const Self) f64 {
        var sum: f64 = 0;
        const mean = self.gene_mean();
        for (0..self.genes.items.len) |i| {
            const diff = self.genes.items[i] - mean;
            sum += diff * diff;
        }
        return sum / @as(f64, @floatFromInt(self.genes.items.len));
    }
    pub fn getRedFromVariance(self: *const Self, variance: f64) u8 {
        return @as(
            u8,
            @intFromFloat(std.math.exp(
                -(std.math.pow(
                    f64,
                    variance,
                    self.config.variance_power,
                ) / self.config.variance_scale) * self.config.variance_max,
            )),
        );
    }
    pub fn tick(self: *Self, prng: *std.Random.Xoshiro256) void {
        self.x += @as(i32, @intCast(prng.random().int(u32) % 7)) - 3;
        self.y += @as(i32, @intCast(prng.random().int(u32) % 7)) - 3;
        if (prng.random().float(f64) < self.config.mutation_probability) {
            self.mutate(prng);
        }
    }
    pub fn mutate(self: *Self, prng: *std.Random.Xoshiro256) void {
        for (0..self.genes.items.len) |i| {
            self.genes.items[i] += prng.random().float(f64) * (2 * self.config.mutation_deviation) - self.config.mutation_deviation;
        }
    }
};
