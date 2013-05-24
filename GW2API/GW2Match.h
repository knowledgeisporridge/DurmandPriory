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
    NSString * type_;
}

@property (nonatomic) GW2MatchScores scores;
@property (nonatomic, copy) NSString * type;

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
}

@property (nonatomic, strong) GW2World * redWorld;
@property (nonatomic, strong) GW2World * greenWorld;
@property (nonatomic, strong) GW2World * blueWorld;
@property (nonatomic, copy) NSString * match_id;
@property (nonatomic) GW2MatchScores totalScores;

- (id)initWithMatchId:(NSString *)match_id;

+ (NSArray *)matches;

- (NSArray *)maps;

@end
