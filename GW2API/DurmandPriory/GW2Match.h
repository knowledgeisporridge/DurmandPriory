//
//  GW2Match.h
//  GW2API
//

#import <Foundation/Foundation.h>
#import "GW2API.h"




typedef struct {
    int red;
    int green;
    int blue;
} GW2MatchScores;


@interface GW2MatchMap : NSObject {
    
@protected
    GW2MatchScores scores_;
    GW2MatchScores tickScores_;
    NSString * type_;
    
    NSMutableArray * objectives_;
}

@property (nonatomic) GW2MatchScores scores;
@property (nonatomic) GW2MatchScores tickScores;
@property (nonatomic, copy) NSString * type;

- (void)parseObjectives:(NSArray *)objectives;

- (int)tickForTeamColor:(GW2MatchTeamColor)color;
- (int)tickTotal;

@end



@class GW2World;

@interface GW2Match : NSObject <GW2APIServiceBackedObject> {
    
@protected
    GW2World * redWorld_;
    GW2World * greenWorld_;
    GW2World * blueWorld_;
    
    NSString * match_id_;
    NSMutableArray * maps_;
    
    GW2MatchScores totalScores_;
    GW2MatchScores tickScores_;
}

@property (nonatomic, strong) GW2World * redWorld;
@property (nonatomic, strong) GW2World * greenWorld;
@property (nonatomic, strong) GW2World * blueWorld;
@property (nonatomic, copy) NSString * match_id;
@property (nonatomic) GW2MatchScores totalScores;
@property (nonatomic) GW2MatchScores tickScores;


- (id)initWithMatchId:(NSString *)match_id;

+ (NSArray *)matches;

- (NSArray *)maps;
- (GW2MatchMap *)mapByTypeName:(NSString *)name;

- (NSArray *)worldsOtherThanId:(NSString *)world_id;
- (GW2MatchTeamColor)teamColorForWorld:(GW2World *)world;

@end
