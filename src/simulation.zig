const std = @import("std");
const renderers = @import("renderer.zig");

pub const Entity = @import("simulation/entity.zig").Entity;
pub const SimulationError = @import("simulation/error.zig").SimulationError;
const configFile = @import("simulation/config.zig");
pub const SimulationConfig = configFile.SimulationConfig;
pub const EntityConfig = configFile.EntityConfig;

pub const Simulation = struct {
    const Self = @This();
    gene_allocator: std.mem.Allocator,
    entities: std.ArrayList(Entity),
    next_id: u32,
    prng: *std.Random.Xoshiro256,
    config: SimulationConfig,

    pub fn init(
        allocator: std.mem.Allocator,
        gene_allocator: std.mem.Allocator,
        prng: *std.Random.Xoshiro256,
        config: SimulationConfig,
    ) SimulationError!Self {
        return .{
            .entities = try std.ArrayList(Entity).initCapacity(
                allocator,
                config.max_entities,
            ),
            .gene_allocator = gene_allocator,
            .next_id = 0,
            .prng = prng,
            .config = config,
        };
    }
    pub fn deinit(self: *Self) void {
        self.entities.deinit();
    }

    pub fn add_entity(self: *Self, x: i32, y: i32, randomize_gene: bool) SimulationError!usize {
        if (self.entities.items.len >= self.config.max_entities) {
            return SimulationError.TooManyEntities;
        }
        var entity = try Entity.init(
            self.gene_allocator,
            self.config.entity_config,
            self.next_id,
            x,
            y,
        );
        if (randomize_gene) {
            entity.randomize(self.prng);
        }
        self.entities.appendAssumeCapacity(entity);
        self.next_id += 1;
        return self.entities.items.len - 1;
    }
    pub fn remove_entity(self: *Self, id: u32) bool {
        for (0..self.entities.items.len) |i| {
            if (self.entities.items[i].id != id) {
                continue;
            }
            _ = self.entities.swapRemove(i);
            return true;
        }
        return false;
    }
    pub fn remove_entity_with_index(self: *Self, entity_index: usize) bool {
        if (entity_index >= self.entities.items.len) {
            return false;
        }
        _ = self.entities.swapRemove(entity_index);
        return true;
    }
    pub fn mate_random_entities(self: *Self) SimulationError!void {
        if (self.entities.items.len < 2) {
            return SimulationError.TooLittleEntities;
        }
        if (self.entities.items.len >= self.config.max_entities) {
            return SimulationError.TooManyEntities;
        }
        const parent1_index = self.prng.random().int(u32) % self.entities.items.len;
        const parent2_index = self.prng.random().int(u32) % self.entities.items.len;
        _ = try self.mate(
            &self.entities.items[parent1_index],
            &self.entities.items[parent2_index],
        );
    }
    pub fn mate(
        self: *Self,
        parent1: *const Entity,
        parent2: *const Entity,
    ) SimulationError!void {
        const childIndex = try self.add_entity(600, 400, false);
        const child = &self.entities.items[childIndex];
        for (0..child.genes.items.len) |i| {
            if (i > child.genes.items.len / 2) {
                child.genes.items[i] = parent1.genes.items[i];
            } else {
                child.genes.items[i] = parent2.genes.items[i];
            }
        }
        return;
    }
    pub fn update(self: *Self, frame: u32) SimulationError!void {
        for (0..self.entities.items.len) |i| {
            const entity = &self.entities.items[i];
            entity.tick(self.prng);
        }
        if (frame % self.config.new_entity_after_every == 0) {
            for (0..10) |_| {
                try self.mate_random_entities();
                const target_index = self.prng.random().int(u32) % self.entities.items.len;
                _ = self.remove_entity_with_index(target_index);
            }
        }
    }
};
