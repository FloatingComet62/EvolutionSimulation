const std = @import("std");

pub const Entity = struct {
    id: u32,
    x: u32,
    y: u32,

    pub fn new(id: u32, x: u32, y: u32) Entity {
        return Entity{
            .id = id,
            .x = x,
            .y = y,
        };
    }
};

pub const Simulation = struct {
    const Self = @This();
    entities: std.ArrayList(Entity),
    next_id: u32,
    prng: *std.Random.Xoshiro256,

    pub fn init(allocator: std.mem.Allocator, prng: *std.Random.Xoshiro256) Self {
        return .{
            .entities = std.ArrayList(Entity).init(allocator),
            .next_id = 0,
            .prng = prng,
        };
    }
    pub fn deinit(self: *Self) void {
        self.entities.deinit();
    }

    pub fn add_entity(self: *Self, x: u32, y: u32) !void {
        const entity = Entity.new(self.next_id, x, y);
        try self.entities.append(entity);
        self.next_id += 1;
    }

    pub fn remove_entity(self: *Self, id: u32) !void {
        const index = try self.entities.indexOf(Entity.new(id, 0, 0));
        try self.entities.removeAt(index);
    }

    pub fn update(self: *Self) void {
        for (0..self.entities.items.len) |i| {
            const entity = &self.entities.items[i];
            const x_offset = self.prng.random().int(u32) % 3;
            const y_offset = self.prng.random().int(u32) % 3;
            if (self.prng.random().boolean()) {
                entity.x += x_offset;
            } else if (entity.x > x_offset) {
                entity.x -= x_offset;
            }

            if (self.prng.random().boolean()) {
                entity.y += y_offset;
            } else if (entity.y > y_offset) {
                entity.y -= y_offset;
            }
        }
    }
};
