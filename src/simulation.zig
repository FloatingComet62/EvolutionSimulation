const std = @import("std");

pub const Entity = struct {
    id: u32,
    x: i32,
    y: i32,

    pub fn new(id: u32, x: i32, y: i32) Entity {
        return .{
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

    pub fn add_entity(self: *Self, x: i32, y: i32) !void {
        const entity = Entity.new(self.next_id, x, y);
        try self.entities.append(entity);
        self.next_id += 1;
    }
    pub fn remove_entity(self: *Self, id: u32) !void {
        for (0..self.entities.items.len) |i| {
            if (self.entities.items[i].id != id) {
                continue;
            }
            try self.entities.swapRemove(i);
            return;
        }
    }
    pub fn update(self: *Self) void {
        for (0..self.entities.items.len) |i| {
            const entity = &self.entities.items[i];
            entity.x += @as(i32, @intCast(self.prng.random().int(u32) % 7)) - 3;
            entity.y += @as(i32, @intCast(self.prng.random().int(u32) % 7)) - 3;
        }
    }
};
