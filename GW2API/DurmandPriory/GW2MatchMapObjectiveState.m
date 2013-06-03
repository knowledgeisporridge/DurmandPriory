//
//  GW2MatchMapObjectiveState.m
//  WubWub
//
//  Created by daniel wartnaby on 30/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import "GW2MatchMapObjectiveState.h"


@implementation GW2MatchMapObjectiveState

@synthesize objective = objective_;
@synthesize owningTeamColor = owningTeamColor_;
@synthesize owningGuildId = owningGuildId_;

- (BOOL)isClaimed {
    return (owningGuildId_ != nil);
}

@end
