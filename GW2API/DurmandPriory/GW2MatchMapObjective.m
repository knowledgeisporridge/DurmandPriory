//
//  GW2MatchMapObjective.m
//  WubWub
//
//  Created by daniel wartnaby on 30/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import "GW2MatchMapObjective.h"

@implementation GW2MatchMapObjective


- (id)initWithObjectiveId:(NSString *)objective_id {
    self = [super init];
    if ( self ) {
        self.objective_id = objective_id;
    }
    return self;
}


- (int)pointsValue {
    if ( [[self.name lowercaseString] isEqualToString:@"castle"] ) {
        return 35;
    }
    if ( [[self.name lowercaseString] isEqualToString:@"keep"] ) {
        return 25;
    }
    if ( [[self.name lowercaseString] isEqualToString:@"tower"] ) {
        return 10;
    }
    return 5;
}


static NSMutableDictionary * objectivesById_;

+ (NSArray *)objectives {
    return [objectivesById_ allValues];
}

+ (GW2MatchMapObjective *)objectiveById:(NSString *)objective_id {
    if ( [objective_id isKindOfClass:[NSNumber class]] ) {
        objective_id = [(NSNumber *)objective_id stringValue];
    }
    
    return [objectivesById_ objectForKey:objective_id];
}




#pragma mark - GW2 API interfaces -

+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSArray class]] ) {
        [GW2API raiseException:@"GW2MatchMapObjective cannot parse/understand provided data."
                        format:@"Received: %@", [data description]];
    }
    
    if ( !objectivesById_ ) {
        objectivesById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSDictionary * objectiveData in ((NSArray *)data) ) {
        GW2MatchMapObjective * objective = [objectivesById_ objectForKey:[objectiveData objectForKey:@"id"]];
        if ( !objective ) {
            objective = [[GW2MatchMapObjective alloc] initWithObjectiveId:[objectiveData objectForKey:@"id"]];
        }
        
        objective.name = [objectiveData objectForKey:@"name"];
        
        [objectivesById_ setObject:objective
                            forKey:objective.objective_id];
    }
}

@end
