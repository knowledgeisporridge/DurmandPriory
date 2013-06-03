//
//  GW2API.h
//  GW2API
//

#define DurmandPriory [GW2API sharedAPI]

/*
 GW2API, lovingly known as The Durmand Priory.
 
 This is a 'domain first' framework. The idea is that you deal with the domain first and 
 foremost. The services are fully abstracted from the client.
 
 The pattern is simple; domain classes provide class-level methods to manage data. For example
 GW2Item has;
  + (NSArray *)items;
  + (GW2Item *)itemById:(NSString *)item_id;
  + (void)parse:(id)data;
 
 In order to populate items simply ask the API to fetch them;
 
 [DurmandPriory fetch:[GW2Item class] completionBlock:^(id domain) {
     // Called once the API has finished fetching it's data.
 }];
 
 The GW2 Rest service's items endpoint gives all known item IDs, so each item in the collection
 returned by [GW2Item items] contains an ID, but no real data.
 
 In order to get the details of a specific item simply pass that item back to the API;
 
 GW2Item * item = ... // Your item.
 [DurmandPriory fetch:item completionBlock:^(id domain) {
     // Called once the API has finished fetching your item's data.
 }];
 
 This pattern is repeated throughout the API. You take the same approach with recipes, 
 World Vs World matches, events... etc. Pass the CLASS to populate the collections of data, pass
 an instance to populate the details.
 
 GW2API is the main API class. It's a singleton; you access the shared instance using the +sharedAPI
 class method. For your convience you can simply use the 'DurmandPriory' definition...
 
 [DurmandPriory fetch:...] is the same as [[GW2API sharedAPI] fetch:...]
 
 Usage considerations;
  - Be sure to tell the API to fetch items before you fetch recipes.
 
 */

#import <Foundation/Foundation.h>



extern NSString * const kGW2APIRequestParameterWorldID;



#pragma mark - GW2 API-specific types -

typedef enum GW2APIVersion {
    GW2APIVersion_Unknown,
    GW2APIVersion_1
} GW2APIVersion;

typedef enum GW2APIDomainCollection {
    GW2APIDomainCollectionEverything,
    GW2APIDomainCollectionEvents,
    GW2APIDomainCollectionWorldVsWorld,
    GW2APIDomainCollectionItems,
    GW2APIDomainCollectionRecipes
} GW2APIDomainCollection;


#pragma mark - GW2 Domain-specific types -

typedef enum GW2Region {
    GW2Region_Unknown,
    GW2Region_US,
    GW2Region_EU
} GW2Region;

typedef enum GW2Language {
    GW2LanguageEnglish,
    GW2LanguageFrench,
    GW2LanguageGerman,
    GW2LanguageSpanish
} GW2Language;


#pragma mark - GW2 WvW types - 

typedef enum GW2MatchTeamColor {
    GW2MatchTeamColorRed,
    GW2MatchTeamColorGreen,
    GW2MatchTeamColorBlue
} GW2MatchTeamColor;



@protocol GW2APIServiceBackedObject <NSObject>

@optional

// Data is deliberately vague; depending on the source JSON we may have arrays, dictionaries or something else. It's
// ultimately the responsibility of the implementing class to make sense of that.
+ (void)parse:(id)data;
- (void)parse:(id)data;

+ (void)parseNames:(id)data;

/**
 Allows domain objects to tell the API of additional domain objects that integral and 
 required. For example a recipe makes little sense if the item it produces and the items 
 it requires to craft are unavailable.
 
 This allows the API to ensure that items are fetched before the recipe is returned to 
 the caller, ensuring a sensible dataset and a limited number of API calls. It also allows 
 the API to take advantage of in-memory domain objects without the need for client code 
 to track or understand these relationships.
 */
- (NSArray *)requiredDomainObjects;

@end


typedef void (^GW2APIDomainCollectionCompleted)(GW2APIDomainCollection collection);
typedef void (^GW2APIDomainCompleted)(id domain);



@interface GW2APIEndpoint : NSObject {
    
@protected
    NSString * endpoint_;
    NSString * namesEndpoint_;
    NSArray  * parameterNames_;
}

@property (nonatomic, copy) NSString * endpoint;
@property (nonatomic, copy) NSString * namesEndpoint;

@property (nonatomic, strong) NSArray * parameterNames;

- (BOOL)requiresNames;

+ (GW2APIEndpoint *)generateEndpointForDomain:(id)domain
                                 withLanguage:(NSString *)language
                                   andVersion:(GW2APIVersion)version;

+ (NSString *)buildEndpointURL:(NSString *)endpointName
                parameterNames:(NSArray *)parameters
                  restrictions:(NSArray *)restrictions
                     forDomain:(id)domain
                  withLanguage:(NSString *)language
                    andVersion:(GW2APIVersion)version;

@end



@class GW2World;

@interface GW2API : NSObject {
    
@protected
    GW2APIVersion version_;
    NSString * language_;
    
    NSMutableDictionary * APIWideRequestParameters_;
}

- (void)setLanguage:(NSString *)language;
- (void)addRequestParameter:(NSString *)name value:(NSString *)value;
- (void)removeRequestParameter:(NSString *)name;
- (NSString *)requestParameter:(NSString *)name;

/**
 Fetches appropriate domain objects for the given collection. This is 
 
 @param collection The desired GW2APIDomainCollection.
 @param completion The completion block invoked once the API has fetched and produced an appropriate domain.
 
 @detail For example you can retrieve all known items;
 
 [[GW2API sharedAPI] fetchCollection:GW2APIDomainCollectionItems
 completionBlock:^(GW2APIDomainCollection collection) {
 
     [GW2Item items];
     [GW2Item itemById:@"12345"];
 }];
 */
- (void)fetchCollection:(GW2APIDomainCollection)collection completionBlock:(GW2APIDomainCollectionCompleted)completion;

/**
 Fetches appropriate domain objects for the given class, or populates a given domain object.
 
 @param domain The domain you wish to fetch/populate.
 @param completion The completion block invoked once the API has fetched and produced an appropriate domain.
 
 @detail For example you can retrieve all known recipes;
 
 [[GW2API sharedAPI] fetch:[GW2Recipe class]
 completionBlock:^(id domain) {
 
     [GW2Recipe recipes];
 }];
 
 Which will populate the class-level dataset for Recipes. You can retreive the details of a specific recipe
 by passing an instance of GW2Recipe that includes a recipe_id. All recipes returned by the above example include
 an id by default.
 
 GW2Recipe * recipe = [[GW2Recipe recipes] lastObject]; // Get any recipe to use as an example.
 [[GW2API sharedAPI] fetch:recipe
 completionBlock:^(id domain) {
 
     NSLog(@"My recipe: %@", recipe.name);
 }];
 */
- (void)fetch:(id)domain completionBlock:(GW2APIDomainCompleted)completion;

+ (GW2API *)sharedAPI;

+ (void)raiseException:(NSString *)message;
+ (void)raiseException:(NSString *)message
                format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);

@end
