//
//  GW2World.h
//  GW2API
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


@class GW2Match;


@interface GW2World : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * name_;
    NSString * world_id_;
    
    GW2Match * matchup_;
}

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * world_id;
@property (strong, nonatomic) GW2Match * matchup;

- (id)initWithWorldId:(NSString *)world_id;

- (GW2Region)region;

+ (NSArray *)worlds;
+ (NSArray *)worldsByRegion:(GW2Region)region;
+ (GW2World *)worldById:(NSString *)world_id;

@end
