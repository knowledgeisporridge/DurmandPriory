//
//  GW2Map.m
//  GW2API
//

#import "GW2Map.h"

@implementation GW2Map

@synthesize map_id = map_id_;
@synthesize name = name_;

- (id)initWithMapId:(NSString *)map_id {
    self = [super init];
    if ( self ) {
        self.map_id = map_id;
    }
    
    return self;
}



static NSMutableDictionary * mapsById_;

+ (NSArray *)maps {
    return [mapsById_ allValues];
}


+ (GW2Map *)mapById:(NSString *)map_id {
    if ( [map_id isKindOfClass:[NSNumber class]] ) {
        map_id = [(NSNumber *)map_id stringValue];
    }
    
    return [mapsById_ objectForKey:map_id];
}



#pragma mark - GW2 API interfaces -

+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSArray class]] ) {
        [GW2API raiseException:@"GW2Map cannot parse/understand provided data."
                        format:@"Received: %@", [data description]];
    }
    
    if ( !mapsById_ ) {
        mapsById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSDictionary * mapData in ((NSArray *)data) ) {
        GW2Map * map = [mapsById_ objectForKey:[mapData objectForKey:@"id"]];
        if ( !map ) {
            map = [[GW2Map alloc] initWithMapId:[mapData objectForKey:@"id"]];
        }
        
        map.name = [mapData objectForKey:@"name"];
        
        [mapsById_ setObject:map
                      forKey:map.map_id];
    }
}

@end
