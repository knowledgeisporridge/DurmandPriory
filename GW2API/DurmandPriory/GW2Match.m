//
//  GW2Match.m
//  GW2API
//

#import "GW2Match.h"
#import "GW2World.h"



@implementation GW2MatchMap

@synthesize scores = scores_;
@synthesize type = type_;

@end



@implementation GW2Match

@synthesize redWorld = redWorld_;
@synthesize blueWorld = blueWorld_;
@synthesize greenWorld = greenWorld_;
@synthesize match_id = match_id_;
@synthesize totalScores = totalScores_;


static NSMutableDictionary * matchesById_;

- (id)initWithMatchId:(NSString *)match_id {
    self = [super init];
    if ( self ) {
        self.match_id = match_id;
    }
    
    return self;
}

+ (NSArray *)matches {
    return [matchesById_ allValues];
}

- (NSArray *)maps {
    return maps_;
}

#pragma mark - GW2 API interfaces -

+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSDictionary class]] ) {
        [GW2API raiseException:@"GW2MatchUp cannot parse/understand provided data."
                        format:@"Received: %@", [data description]];
    }
    
    if ( !matchesById_ ) {
        matchesById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    NSArray * matches = [(NSDictionary *)data objectForKey:@"wvw_matches"];
    for ( NSDictionary * matchData in matches ) {
        GW2Match * match = [matchesById_ objectForKey:[matchData objectForKey:@"wvw_match_id"]];
        if ( !match ) {
            match = [[GW2Match alloc] initWithMatchId:[matchData objectForKey:@"wvw_match_id"]];
        }
        
        match.redWorld   = [GW2World worldById:[matchData objectForKey:@"red_world_id"]];
        match.greenWorld = [GW2World worldById:[matchData objectForKey:@"green_world_id"]];
        match.blueWorld  = [GW2World worldById:[matchData objectForKey:@"blue_world_id"]];
        
        match.redWorld.matchup = match;
        match.greenWorld.matchup = match;
        match.blueWorld.matchup = match;
        
        [matchesById_ setObject:match
                         forKey:match.match_id];
    }
}

- (void)parse:(id)data {
    maps_ = [[NSMutableArray alloc] init];
    
    NSDictionary * matchData = (NSDictionary *)data;
    
    self.match_id = [matchData objectForKey:@"match_id"];
    
    NSArray * scores = [matchData objectForKey:@"scores"];
    totalScores_.red   = [[scores objectAtIndex:0] intValue];
    totalScores_.green = [[scores objectAtIndex:2] intValue];
    totalScores_.blue  = [[scores objectAtIndex:1] intValue];
    
    // Let's get our map information...
    for ( NSDictionary * mapData in [matchData objectForKey:@"maps"] ) {
        GW2MatchMap * map = [[GW2MatchMap alloc] init];
        
        NSArray * scoreData = [mapData objectForKey:@"scores"];
        GW2MatchScores scores;
        scores.red   = [[scoreData objectAtIndex:0] intValue];
        scores.green = [[scoreData objectAtIndex:2] intValue];
        scores.blue  = [[scoreData objectAtIndex:1] intValue];
        
        map.scores = scores;
        map.type = [mapData objectForKey:@"type"];
        
        // @TODO Objectives data.
        
        [maps_ addObject:map];
    }
}

@end
