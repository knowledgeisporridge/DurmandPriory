//
//  GW2Item.h
//  GW2API
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


extern NSString * const kItemAttributeType;
extern NSString * const kItemAttributeDamageType;
extern NSString * const kItemAttributeMinPower;
extern NSString * const kItemAttributeMaxPower;
extern NSString * const kItemAttributeDefense;
extern NSString * const kItemAttributeBuff;
extern NSString * const kItemAttributePrecision;
extern NSString * const kItemAttributeToughness;
extern NSString * const kItemAttributePower;
extern NSString * const kItemAttributeConditionDamage;


@interface GW2Item : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * item_id_;
    NSString * name_;
    NSString * itemDescription_;
    NSString * type_;
    NSString * rarity_;
    
    NSUInteger level_;
    NSUInteger vendorValue_;
    
    NSMutableDictionary * attributes_;
}

@property (nonatomic, copy) NSString * item_id;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * itemDescription;
@property (nonatomic, copy) NSString * type;
@property (nonatomic, copy) NSString * rarity;

@property (nonatomic, retain) NSMutableDictionary * attributes;

@property (nonatomic) NSUInteger level;
@property (nonatomic) NSUInteger vendorValue;


- (id)initWithItemId:(NSString *)item_id;

+ (NSArray *)items;
+ (GW2Item *)itemById:(NSString *)item_id;

- (NSUInteger)integerAttribute:(NSString *)attribute;
- (NSString *)attribute:(NSString *)attribute;

- (void)setAttribute:(NSString *)attribute integerValue:(NSUInteger)value;
- (void)setAttribute:(NSString *)attribute value:(NSString *)value;

@end

