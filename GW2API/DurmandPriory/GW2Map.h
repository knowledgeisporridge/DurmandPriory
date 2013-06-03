//
//  GW2Map.h
//  GW2API
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


@class GW2MatchMapObjective;

@interface GW2Map : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * map_id_;
    NSString * name_;
}

@property (nonatomic, copy) NSString * map_id;
@property (nonatomic, copy) NSString * name;

- (id)initWithMapId:(NSString *)map_id;

+ (NSArray *)maps;
+ (GW2Map *)mapById:(NSString *)map_id;

- (int)tickByWorldColor:(GW2MatchTeamColor)color;

@end
