//
//  GW2MatchMapObjective.h
//  WubWub
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


@interface GW2MatchMapObjective : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * objective_id_;
    NSString * name_;
}

@property (nonatomic, copy) NSString * objective_id;
@property (nonatomic, copy) NSString * name;

- (id)initWithObjectiveId:(NSString *)objective_id;

+ (NSArray *)objectives;
+ (GW2MatchMapObjective *)objectiveById:(NSString *)objective_id;

- (int)pointsValue;

@end
