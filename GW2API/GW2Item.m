//
//  GW2Item.m
//  GW2API
//

#import "GW2Item.h"


NSString * const kItemAttributeType = @"type";
NSString * const kItemAttributeDamageType = @"damage_type";
NSString * const kItemAttributeMinPower = @"min_power";
NSString * const kItemAttributeMaxPower = @"max_power";
NSString * const kItemAttributeDefense = @"defense";
NSString * const kItemAttributeBuff = @"buff";
NSString * const kItemAttributePrecision = @"Precision";
NSString * const kItemAttributeToughness = @"Toughness";
NSString * const kItemAttributePower = @"Power";
NSString * const kItemAttributeConditionDamage = @"ConditionDamage";


@interface GW2Item (Private)

- (void)parseWeapon:(NSDictionary *)weaponData;

@end



@implementation GW2Item

@synthesize item_id = item_id_;
@synthesize name = name_;
@synthesize itemDescription = itemDescription_;
@synthesize type = type_;
@synthesize rarity = rarity_;
@synthesize level = level_;
@synthesize vendorValue = vendorValue_;
@synthesize attributes = attributes_;


- (id)initWithItemId:(NSString *)item_id {
    self = [super init];
    if ( self ) {
        self.attributes = [[NSMutableDictionary alloc] init];
        self.item_id = item_id;
    }
    
    return self;
}


__strong static NSMutableDictionary * itemsById_;

+ (NSArray *)items {
    return [itemsById_ allValues];
}

+ (GW2Item *)itemById:(NSString *)item_id {
    if ( [item_id isKindOfClass:[NSNumber class]] ) {
        item_id = [(NSNumber *)item_id stringValue];
    }
    
    return [itemsById_ objectForKey:item_id];
}


+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSDictionary class]] ) {
        [GW2API raiseException:@"GW2Item cannot parse/understand provided data, expects a dictionary."];
    }
    
    if ( !itemsById_ ) {
        itemsById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSNumber * itemId in (NSArray *)[(NSDictionary *)data objectForKey:@"items"] ) {
        GW2Item * item = [itemsById_ objectForKey:[itemId stringValue]];
        if ( !item ) {
            item = [[GW2Item alloc] initWithItemId:[itemId stringValue]];
            
            [itemsById_ setObject:item
                           forKey:item.item_id];
        }
    }
}


- (void)parse:(id)data {
    NSDictionary * itemData = (NSDictionary *)data;
    
    self.name = [itemData objectForKey:@"name"];
    self.itemDescription = [itemData objectForKey:@"description"];
    self.type = [itemData objectForKey:@"type"];
    self.rarity = [itemData objectForKey:@"rarity"];
    self.level = [[itemData objectForKey:@"level"] integerValue];
    self.vendorValue = [[itemData objectForKey:@"vendorValue"] integerValue];
    
    // Is this is a weapon?
    if ( [itemData objectForKey:@"weapon"] ) {
        [self parseWeapon:[itemData objectForKey:@"weapon"]];
    }
}

- (void)parseWeapon:(NSDictionary *)weaponData {
    [self setAttribute:kItemAttributeType
                 value:[weaponData objectForKey:@"type"]];
    
    [self setAttribute:kItemAttributeDamageType
                 value:[weaponData objectForKey:@"damage_type"]];
    
    [self setAttribute:kItemAttributeMinPower
                 value:[weaponData objectForKey:@"min_power"]];

    [self setAttribute:kItemAttributeMaxPower
                 value:[weaponData objectForKey:@"max_power"]];
    
    [self setAttribute:kItemAttributeDefense
                 value:[weaponData objectForKey:@"defense"]];
    
    // Next level of data...
    weaponData = [weaponData objectForKey:@"infix_upgrade"];
    
    // Bit of an oddity with the API. Buff is ALWAYS provided, but may be an empty string. This is unsual, but we'll roll with it.
    if ( ![[weaponData objectForKey:@"buff"] isKindOfClass:[NSString class]] ) {
        
    }
    
    for ( NSDictionary * attributeData in (NSArray *)[weaponData objectForKey:@"attributes"] ) {
        [self setAttribute:[attributeData objectForKey:@"attribute"]
                     value:[attributeData objectForKey:@"modifier"]];
    }
}



- (NSUInteger)integerAttribute:(NSString *)attribute {
    return [[attributes_ objectForKey:attribute] integerValue];
}

- (NSString *)attribute:(NSString *)attribute {
    return [attributes_ objectForKey:attribute];    
}

- (void)setAttribute:(NSString *)attribute integerValue:(NSUInteger)value {
    [attributes_ setObject:[NSString stringWithFormat:@"%d", value] forKey:attribute];
}

- (void)setAttribute:(NSString *)attribute value:(NSString *)value {
    [attributes_ setObject:value forKey:attribute];
}

@end
