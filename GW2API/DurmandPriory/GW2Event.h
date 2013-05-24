//
//  GW2Event.h
//  GW2API
//
//  Created by daniel wartnaby on 24/05/2013.
//  Copyright (c) 2013 Knowledge Is Porridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


typedef enum GW2EventState {
    GW2EventStateUnknown,
    GW2EventStateActive,
    GW2EventStateSuccess,
    GW2EventStateFail,
    GW2EventStateWarmup,
    GW2EventStatePreparation
} GW2EventState;


@class GW2Map;
@class GW2World;

@interface GW2Event : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * event_id_;
    NSString * state_;
    NSString * name_;
    
    GW2World * world_;
    GW2Map * map_;
}

@property (nonatomic, copy) NSString * event_id;
@property (nonatomic, copy) NSString * state;
@property (nonatomic, copy) NSString * name;

@property (nonatomic, retain) GW2World * world;
@property (nonatomic, retain) GW2Map * map;

- (id)initWithEventId:(NSString *)event_id;

- (GW2EventState)eventState;

+ (NSArray *)events;
+ (GW2Event *)eventById:(NSString *)event_id;

@end
