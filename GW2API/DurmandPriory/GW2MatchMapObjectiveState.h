//
//  GW2MatchMapObjectiveState.h
//  WubWub
//
//  Created by daniel wartnaby on 30/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GW2API.h"
#import "GW2MatchMapObjective.h"


@interface GW2MatchMapObjectiveState : NSObject {
    
@protected
    GW2MatchTeamColor owningTeamColor_;
    GW2MatchMapObjective * objective_;
    
    NSString * owningGuildId_;
}

@property (nonatomic, strong) GW2MatchMapObjective * objective;
@property (nonatomic, strong) NSString * owningGuildId;
@property (nonatomic) GW2MatchTeamColor owningTeamColor;

- (BOOL)isClaimed;

@end
