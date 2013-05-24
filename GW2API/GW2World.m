//
//  GW2World.m
//  GW2API
//

#import "GW2World.h"

@implementation GW2World

@synthesize name = name_;
@synthesize world_id = world_id_;
@synthesize matchup = matchup_;


- (id)initWithWorldId:(NSString *)world_id {
    self = [super init];
    if ( self ) {
        self.world_id = world_id;
    }
    
    return self;
}


- (GW2Region)region {
    if ( [world_id_ hasPrefix:@"10"] ) {
        return GW2Region_US;
    }
    else if ( [world_id_ hasPrefix:@"20"] ) {
        return GW2Region_EU;
    }
    else if ( [world_id_ hasPrefix:@"21"] ) {
        return GW2Region_EU_FR;
    }
    else if ( [world_id_ hasPrefix:@"22"] ) {
        return GW2Region_EU_DE;
    }
    else if ( [world_id_ hasPrefix:@"23"] ) {
        return GW2Region_EU_ES;
    }
    else {
        return GW2Region_Unknown;
    }
}



static NSMutableDictionary * worldsById_;

+ (NSArray *)worlds {
    return [worldsById_ allValues];
}


+ (GW2World *)worldById:(NSString *)world_id {
    if ( [world_id isKindOfClass:[NSNumber class]] ) {
        world_id = [(NSNumber *)world_id stringValue];
    }
    
    return [worldsById_ objectForKey:world_id];
}


+ (NSArray *)worldsByRegion:(GW2Region)region {
    NSMutableArray * worlds = [NSMutableArray arrayWithCapacity:0];
    for (GW2World * world in [self worlds]) {
        if ( world.region == region ) {
            [worlds addObject:world];
        }
    }
    
    return worlds;
}

+ (GW2World *)worldByName:(NSString *)name {
    for (GW2World * world in [self worlds]) {
        if ( [world.name isEqualToString:name] ) {
            return world;
        }
    }
    
    return nil;
}

#pragma mark - GW2 API interfaces -

+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSArray class]] ) {
        [GW2API raiseException:@"GW2World cannot parse/understand provided data."
                        format:@"Received: %@", [data description]];
    }
    
    if ( !worldsById_ ) {
        worldsById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSDictionary * worldData in ((NSArray *)data) ) {
        GW2World * world = [worldsById_ objectForKey:[worldData objectForKey:@"id"]];
        if ( !world ) {
            world = [[GW2World alloc] initWithWorldId:[worldData objectForKey:@"id"]];
        }
        
        world.name = [worldData objectForKey:@"name"];
        
        [worldsById_ setObject:world
                        forKey:world.world_id];
    }
}

@end
