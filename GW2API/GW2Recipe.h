//
//  GW2Recipe.h
//  GW2API
//

#import <Foundation/Foundation.h>
#import "GW2API.h"


@class GW2Item;


@interface GW2RecipeIngredient : NSObject {

@protected
    GW2Item * item_;
    NSUInteger count_;
}

@property (nonatomic, strong) GW2Item * item;
@property (nonatomic) NSUInteger numberRequired;

- (id)initWithItem:(GW2Item *)item andNumberRequired:(NSUInteger)numberRequired;

@end


@interface GW2Recipe : NSObject <GW2APIServiceBackedObject> {
    
@protected
    NSString * recipe_id_;
    
    NSUInteger numberOfItemsProduced_;
    NSUInteger timeToCraft_;
    NSUInteger minimumCraftingLevel_;
    
    GW2Item * producesItem_;
    NSMutableArray * ingredients_;
}

@property (nonatomic, copy) NSString * recipe_id;
@property (nonatomic, strong) GW2Item * producesItem;
@property (nonatomic, retain) NSMutableArray * ingredients;
@property (nonatomic) NSUInteger numberOfItemsProduced;
@property (nonatomic) NSUInteger timeToCraft;
@property (nonatomic) NSUInteger minimumCraftingLevel;

- (id)initWithRecipeId:(NSString *)recipe_id;

+ (NSArray *)recipes;
+ (GW2Recipe *)recipeById:(NSString *)recipe_id;

@end
