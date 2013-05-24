//
//  GW2Recipe.m
//  GW2API
//

#import "GW2Recipe.h"
#import "GW2Item.h"



@implementation GW2RecipeIngredient

@synthesize item = item_;
@synthesize numberRequired = numberRequired_;

- (id)initWithItem:(GW2Item *)item andNumberRequired:(NSUInteger)numberRequired; {
    
    self = [super init];
    if ( self ) {
        self.item = item;
        self.numberRequired = numberRequired;
    }
    return self;
}

@end



@implementation GW2Recipe

@synthesize recipe_id = recipe_id_;
@synthesize producesItem = producesItem_;
@synthesize numberOfItemsProduced = numberOfItemsProduced_;
@synthesize ingredients = ingredients_;
@synthesize timeToCraft = timeToCraft_;
@synthesize minimumCraftingLevel = minimumCraftingLevel_;


- (id)initWithRecipeId:(NSString *)recipe_id {
    self = [self init];
    if ( self ) {
        self.recipe_id = recipe_id;
    }
    return self;
}


static NSMutableDictionary * recipesById_;

+ (NSArray *)recipes {
    return [recipesById_ allValues];
}

+ (GW2Recipe *)recipeById:(NSString *)recipe_id {
    if ( [recipe_id isKindOfClass:[NSNumber class]] ) {
        recipe_id = [(NSNumber *)recipe_id stringValue];
    }
    
    return [recipesById_ objectForKey:recipe_id];
}


+ (void)parse:(id)data {
    if ( ![data isKindOfClass:[NSDictionary class]] ) {
        [GW2API raiseException:@"GW2Recipe cannot parse/understand provided data, expects a dictionary."];
    }
    
    if ( !recipesById_ ) {
        recipesById_ = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    for ( NSString * recipeId in (NSArray *)[(NSDictionary *)data objectForKey:@"recipes"] ) {
        GW2Recipe * recipe = [recipesById_ objectForKey:recipeId];
        if ( !recipe ) {
            recipe = [[GW2Recipe alloc] initWithRecipeId:recipeId];
            
            [recipesById_ setObject:recipe
                             forKey:recipe.recipe_id];
        }
    }
}



- (void)parse:(id)data {
    NSDictionary * recipeData = (NSDictionary *)data;
    
    self.producesItem = [GW2Item itemById:[recipeData objectForKey:@"output_item_id"]];
    self.numberOfItemsProduced = [[recipeData objectForKey:@"output_item_count"] integerValue];
    self.timeToCraft = [[recipeData objectForKey:@"time_to_craft_ms"] integerValue];
    self.minimumCraftingLevel = [[recipeData objectForKey:@"min_rating"] integerValue];
    
    ingredients_ = [[NSMutableArray alloc] initWithCapacity:0];
    for ( NSDictionary * ingredientData in (NSArray *)[recipeData objectForKey:@"ingredients"] ) {
        GW2RecipeIngredient * ingredient = [[GW2RecipeIngredient alloc] initWithItem:[GW2Item itemById:[ingredientData objectForKey:@"item_id"]]
                                                                   andNumberRequired:[[ingredientData objectForKey:@"count"] integerValue]];
        
        [ingredients_ addObject:ingredient];
    }
}


- (NSArray *)requiredDomainObjects {
    // A recipe only really makes sense if the associate items are available, and they may not be, so we're going to tell the API
    // That these items are part of the domain and are required.
    
    NSMutableArray * requiredDomainObjects = [[NSMutableArray alloc] initWithCapacity:1];
    
    [requiredDomainObjects addObject:self.producesItem];
    for ( GW2RecipeIngredient * ingredient in self.ingredients ) {
        [requiredDomainObjects addObject:ingredient.item];
    }
    
    return requiredDomainObjects;
}


@end
