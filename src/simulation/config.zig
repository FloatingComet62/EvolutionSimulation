pub const SimulationConfig = struct {
    pub const Self = @This();
    max_entities: u32,
    new_entity_after_every: u32,
    entity_config: EntityConfig,

    pub fn init(
        max_entities: u32,
        new_entity_after_every: u32,
        entity_config: EntityConfig,
    ) Self {
        return Self{
            .max_entities = max_entities,
            .new_entity_after_every = new_entity_after_every,
            .entity_config = entity_config,
        };
    }
    pub fn default() Self {
        return Self{
            .max_entities = 1000,
            .new_entity_after_every = 10,
            .entity_config = EntityConfig.default(),
        };
    }
};

pub const EntityConfig = struct {
    pub const Self = @This();
    genes_length: u32,
    variance_max: f64,
    variance_power: f64,
    variance_scale: f64,
    mutation_deviation: f64,
    mutation_probability: f64,

    pub fn init(
        genes_length: u32,
        variance_max: f64,
        variance_power: f64,
        variance_scale: f64,
        mutation_deviation: f64,
        mutation_probability: f64,
    ) Self {
        return Self{
            .genes_length = genes_length,
            .variance_max = variance_max,
            .variance_power = variance_power,
            .variance_scale = variance_scale,
            .mutation_deviation = mutation_deviation,
            .mutation_probability = mutation_probability,
        };
    }
    pub fn default() Self {
        return Self{
            .genes_length = 100,
            .variance_max = 255.0,
            .variance_power = 1.2,
            .variance_scale = 10000.0,
            .mutation_deviation = 50,
            .mutation_probability = 0.1,
        };
    }
};
