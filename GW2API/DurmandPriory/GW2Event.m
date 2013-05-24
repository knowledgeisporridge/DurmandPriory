//
//  GW2Event.m
//  GW2API
//
//  Created by daniel wartnaby on 24/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import "GW2Event.h"
#import "GW2World.h"
#import "GW2Map.h"


@implementation GW2Event

@synthesize event_id = event_id_;
@synthesize state = state_;
@synthesize world = world_;
@synthesize name = name_;


- (id)initWithEventId:(NSString *)event_id {
    self = [super init];
    if ( self ) {
        self.event_id = event_id;
    }
    return self;
}


- (GW2EventState)eventState {
    if ( [self.state isEqualToString:@"Active"] ) {
        return GW2EventStateActive;
    }
    else if ( [self.state isEqualToString:@"Success"] ) {
        return GW2EventStateSuccess;
    }
    else if ( [self.state isEqualToString:@"Fail"] ) {
        return GW2EventStateFail;
    }
    else if ( [self.state isEqualToString:@"Warmup"] ) {
        return GW2EventStateWarmup;
    }
    else if ( [self.state isEqualToString:@"Preparation"] ) {
        return GW2EventStatePreparation;
    }
    
    return GW2EventStateUnknown;
}


__strong static NSMutableDictionary * eventNames_;
__strong static NSMutableDictionary * eventsById_;


+ (NSArray *)events {
    return [eventsById_ allValues];
}

+ (GW2Event *)eventById:(NSString *)event_id {
    return [eventsById_ objectForKey:event_id];
}


+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSDictionary class]] ) {
        [GW2API raiseException:@"GW2Event cannot parse/understand provided data, expects a dictionary."];
    }
    
    if ( !eventsById_ ) {
        eventsById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSDictionary * eventData in (NSArray *)[(NSDictionary *)data objectForKey:@"events"] ) {
        GW2Event * event = [eventsById_ objectForKey:[eventData objectForKey:@"event_id"]];
        if ( !event ) {
            event = [[GW2Event alloc] initWithEventId:[eventData objectForKey:@"event_id"]];
            event.name  = [eventNames_ objectForKey:[eventData objectForKey:@"event_id"]];
            event.state = [eventData objectForKey:@"state"];
            event.world = [GW2World worldById:[eventData objectForKey:@"world_id"]];
            event.map   = [GW2Map mapById:[eventData objectForKey:@"map_id"]];
            
            [eventsById_ setObject:event
                            forKey:event.event_id];
        }
    }
}


- (void)parse:(id)data {
    NSDictionary * eventData = (NSDictionary *)data;
    
    self.state = [eventData objectForKey:@"state"];
    self.world = [GW2World worldById:[eventData objectForKey:@"world_id"]];
    self.name  = [eventNames_ objectForKey:[eventData objectForKey:@"event_id"]];
    self.map   = [GW2Map mapById:[eventData objectForKey:@"map_id"]];
}



+ (void)parseNames:(id)data {
    if ( ![data isKindOfClass:[NSArray class]] ) {
        [GW2API raiseException:@"GW2Event cannot parse/understand provided data for names, expects an array."];
    }
    
    if ( !eventNames_ ) {
        eventNames_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSDictionary * eventData in (NSArray *)data ) {
        [eventNames_ setObject:[eventData objectForKey:@"name"]
                        forKey:[eventData objectForKey:@"id"]];
    }
}


@end
