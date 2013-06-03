//
//  GW2Match.m
//  GW2API
//

#import "GW2Match.h"
#import "GW2World.h"
#import "GW2MatchMapObjective.h"
#import "GW2MatchMapObjectiveState.h"


@implementation GW2MatchMap

@synthesize tickScores = tickScores_;
@synthesize scores = scores_;
@synthesize type = type_;

- (void)parseObjectives:(NSArray *)objectives {
    objectives_ = [NSMutableArray array];
    
    for ( NSDictionary * objectiveData in objectives ) {
        GW2MatchMapObjective * objective = [GW2MatchMapObjective objectiveById:[objectiveData objectForKey:@"id"]];
        GW2MatchMapObjectiveState * state = [[GW2MatchMapObjectiveState alloc] init];
        
        NSString * owner = [[objectiveData objectForKey:@"owner"] lowercaseString];
        state.owningTeamColor =
        ( [owner isEqualToString:@"blue"] ? GW2MatchTeamColorBlue :
         ( [owner isEqualToString:@"red"] ? GW2MatchTeamColorRed : GW2MatchTeamColorGreen ));
        
        state.owningGuildId = [objectiveData objectForKey:@"owner_guild"];
        
        state.objective = objective;
        
        [objectives_ addObject:state];
    }
    
    tickScores_.red   = [self tickForTeamColor:GW2MatchTeamColorRed];
    tickScores_.green = [self tickForTeamColor:GW2MatchTeamColorGreen];
    tickScores_.blue  = [self tickForTeamColor:GW2MatchTeamColorBlue];
}

- (int)tickForTeamColor:(GW2MatchTeamColor)color {
    int tick = 0;
    for ( GW2MatchMapObjectiveState * state in objectives_ ) {
        if ( state.owningTeamColor == color ) {
            tick += [state.objective pointsValue];
        }
    }
    return tick;
}

- (int)tickTotal {
    int tick = 0;
    for ( GW2MatchMapObjectiveState * state in objectives_ ) {
        tick += [state.objective pointsValue];
    }
    return tick;
}

@end




@implementation GW2Match

@synthesize redWorld = redWorld_;
@synthesize blueWorld = blueWorld_;
@synthesize greenWorld = greenWorld_;
@synthesize match_id = match_id_;
@synthesize totalScores = totalScores_;
@synthesize tickScores = tickScores_;


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

- (GW2MatchMap *)mapByTypeName:(NSString *)name {
    for ( GW2MatchMap * map in maps_ ) {
        if ( [map.type isEqualToString:name] ) {
            return map;
        }
    }
    return nil;
}

- (GW2MatchTeamColor)teamColorForWorld:(GW2World *)world {
    if ( world == redWorld_ ) {
        return GW2MatchTeamColorRed;
    }
    if ( world == greenWorld_ ) {
        return GW2MatchTeamColorGreen;
    }
    if ( world == blueWorld_ ) {
        return GW2MatchTeamColorBlue;
    }
    return GW2MatchTeamColorGreen;
}


- (NSArray *)worldsOtherThanId:(NSString *)world_id {
    if ( [world_id isEqualToString:redWorld_.world_id] ) {
        return [NSMutableArray arrayWithObjects:greenWorld_, blueWorld_, nil];
    }
    
    if ( [world_id isEqualToString:greenWorld_.world_id] ) {
        return [NSMutableArray arrayWithObjects:redWorld_, blueWorld_, nil];
    }
    
    if ( [world_id isEqualToString:blueWorld_.world_id] ) {
        return [NSMutableArray arrayWithObjects:greenWorld_, redWorld_, nil];
    }
    
    return nil;
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
    
    tickScores_.red   = 0;
    tickScores_.green = 0;
    tickScores_.blue  = 0;
    
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
        
        [map parseObjectives:[mapData objectForKey:@"objectives"]];
        
        [maps_ addObject:map];
        
        tickScores_.red   += map.tickScores.red;
        tickScores_.green += map.tickScores.green;
        tickScores_.blue  += map.tickScores.blue;
    }
}

@end
