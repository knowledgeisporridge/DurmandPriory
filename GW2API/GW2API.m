//
//  GW2API.m
//  GW2API
//

#include <objc/objc-runtime.h>

#import "GW2API.h"
#import "AFNetworking.h"
#import "GW2World.h"
#import "GW2Match.h"
#import "GW2Recipe.h"
#import "GW2Item.h"
#import "GW2Event.h"
#import "GW2Map.h"


NSString * const kGW2APIRequestParameterWorldID = @"world_id";


#define ENDPOINT_BASE @"https://api.guildwars2.com/v%d/"


@interface GW2API (Private)

- (BOOL)objectsHaveDetails:(NSArray *)objects;

- (void)fetchCollection_EverythingWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion;
- (void)fetchCollection_WorldVsWorldWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion;
- (void)fetchCollection_ItemsWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion;
- (void)fetchCollection_RecipesWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion;
- (void)fetchCollection_EventsWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion;

- (void)invokeRequest:(NSString *)endpoint
              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
              failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;
@end



@implementation GW2APIEndpoint

@synthesize endpoint = endpoint_;
@synthesize namesEndpoint = namesEndpoint_;
@synthesize parameterNames = parameterNames_;


- (BOOL)requiresNames {
    return namesEndpoint_ != nil;
}


+ (GW2APIEndpoint *)generateEndpointForDomain:(id)domain
                                 withLanguage:(NSString *)language
                                   andVersion:(GW2APIVersion)version {
    
    // Load the rest configuration file for the given domain.
    NSString * resource = [[NSBundle mainBundle] pathForResource:NSStringFromClass([domain class]) ofType:@"json"];
    if ( !resource ) {
        [GW2API raiseException:@"Missing .json configuration."];
    }
    
    NSData * endpointConfigurationData = [[NSString stringWithContentsOfFile:resource
                                                                    encoding:NSUTF8StringEncoding
                                                                       error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * endpointConfiguration = [NSJSONSerialization JSONObjectWithData:endpointConfigurationData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
    
    BOOL isTopLevel = class_isMetaClass(object_getClass(domain));
    GW2APIEndpoint * endpoint = [[GW2APIEndpoint alloc] init];
    
    NSString * appropriateEndpoint = [endpointConfiguration objectForKey:@"endpoint"];
    if ( !isTopLevel ) {
        appropriateEndpoint = [endpointConfiguration objectForKey:@"details_endpoint"];
    }
    
    endpoint.parameterNames = [endpointConfiguration objectForKey:@"parameters"];
    endpoint.endpoint = [self buildEndpointURL:appropriateEndpoint
                                parameterNames:( isTopLevel ? nil : endpoint.parameterNames )
                                  restrictions:[endpointConfiguration objectForKey:@"restrictions"]
                                     forDomain:domain
                                  withLanguage:language
                                    andVersion:version];
    
    if ( isTopLevel && [endpointConfiguration objectForKey:@"names_endpoint"] ) {
        endpoint.namesEndpoint = [self buildEndpointURL:[endpointConfiguration objectForKey:@"names_endpoint"]
                                         parameterNames:nil
                                           restrictions:nil
                                              forDomain:domain
                                           withLanguage:language
                                             andVersion:version];
    }
    
    return endpoint;
}

+ (NSString *)buildEndpointURL:(NSString *)endpointName
                parameterNames:(NSArray *)parameters
                  restrictions:(NSArray *)restrictions
                     forDomain:(id)domain
                  withLanguage:(NSString *)language
                    andVersion:(GW2APIVersion)version {
    
    NSMutableString * endpoint = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:ENDPOINT_BASE, version]];
    [endpoint appendFormat:@"%@", endpointName];
    [endpoint appendFormat:@"?lang=%@", language];
    
    // Do we have any parameters to send with the request?
    if ( parameters ) {
        // Iterate the parameter names and build an appropriate set of GET parameters.
        for ( NSString * parameterName in parameters ) {
            if ( ![domain valueForKey:parameterName] ) {
                [GW2API raiseException:@"Parameter missing."
                                format:@"nil value found for %@", parameterName];
            }
            
            [endpoint appendFormat:@"&%@=%@", parameterName, [domain valueForKey:parameterName]];
        }
    }
    
    if ( restrictions ) {
        // Iterate the parameter names and build an appropriate set of GET parameters.
        for ( NSString * parameterName in restrictions ) {
            NSString * value = [[GW2API sharedAPI] requestParameter:parameterName];
            if ( value ) {
                [endpoint appendFormat:@"&%@=%@", parameterName, value];
            }
        }
    }
    
    return endpoint;
}

@end

/*
 
 */


@implementation GW2API

- (id)init {
    self = [super init];
    if ( self ) {
        version_ = GW2APIVersion_1;
        
        [self setLanguage:@"en"];
    }
    return self;
}


- (void)setLanguage:(NSString *)language {
    language_ = language;
}


- (void)addRequestParameter:(NSString *)name value:(NSString *)value {
    if ( !APIWideRequestParameters_ ) {
        APIWideRequestParameters_ = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    [APIWideRequestParameters_ setObject:value
                                  forKey:name];
}

- (void)removeRequestParameter:(NSString *)name {
    [APIWideRequestParameters_ removeObjectForKey:name];
}

- (NSString *)requestParameter:(NSString *)name {
    return [APIWideRequestParameters_ objectForKey:name];
}


- (void)fetchCollection:(GW2APIDomainCollection)collection
        completionBlock:(GW2APIDomainCollectionCompleted)completion {
    
    if ( collection == GW2APIDomainCollectionEverything ) {
        [self fetchCollection_EverythingWithCompletionBlock:completion];
    }
    else if ( collection == GW2APIDomainCollectionWorldVsWorld ) {
        [self fetchCollection_WorldVsWorldWithCompletionBlock:completion];
    }
    else if ( collection == GW2APIDomainCollectionItems ) {
        [self fetchCollection_ItemsWithCompletionBlock:completion];
    }
    else if ( collection == GW2APIDomainCollectionRecipes ) {
        [self fetchCollection_RecipesWithCompletionBlock:completion];
    }
    else if ( collection == GW2APIDomainCollectionEvents ) {
        [self fetchCollection_EventsWithCompletionBlock:completion];
    }
    else {
        [GW2API raiseException:@"Unknown collection."];
    }
}


#pragma mark - Collection fetching -

- (void)fetchCollection_EverythingWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion {
    [self fetchCollection:GW2APIDomainCollectionWorldVsWorld
          completionBlock:^(GW2APIDomainCollection collection) {
              
              GW2World * activeWorld = [GW2World worldById:[self requestParameter:kGW2APIRequestParameterWorldID]];
              [self fetch:activeWorld.matchup completionBlock:^(id domain) {}];
              
              [self fetchCollection:GW2APIDomainCollectionItems
                    completionBlock:^(GW2APIDomainCollection collection) {
                        
                        [self fetchCollection:GW2APIDomainCollectionRecipes
                              completionBlock:^(GW2APIDomainCollection collection) {
                                  
                                  [self fetchCollection:GW2APIDomainCollectionEvents
                                        completionBlock:^(GW2APIDomainCollection collection) {
                                            
                                            completion(GW2APIDomainCollectionEverything);
                                        }];
                              }];
                    }];
          }];
}

- (void)fetchCollection_WorldVsWorldWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion {
    // So we're going to load a collection of data for WubWub. We'll start with Worlds.
    [[GW2API sharedAPI] fetch:[GW2World class]
              completionBlock:^(id domain) {
                  
                  // ... and then ask for match information...
                  [[GW2API sharedAPI] fetch:[GW2Match class]
                            completionBlock:^(id domain) {
                                
                                // ... and we'll finish by telling the delegate that our collection has been loaded.
                                completion(GW2APIDomainCollectionWorldVsWorld);
                            }];
              }];
}

- (void)fetchCollection_ItemsWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion {
    // So we're going to load a collection of data for items.
    [[GW2API sharedAPI] fetch:[GW2Item class]
              completionBlock:^(id domain) {
                  
                  // ... we'll fetch the first item's data, partly to verify the services are up, but also to make the
                  // model moderately useful on completion.
                  [[GW2API sharedAPI] fetch:[[GW2Item items] objectAtIndex:0]
                            completionBlock:^(id domain) {
                                
                                // ... and we'll finish by telling the delegate that our collection has been loaded.
                                completion(GW2APIDomainCollectionItems);
                            }];
              }];
}

- (void)fetchCollection_RecipesWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion {
    // So we're going to load a collection of data for recipes.
    [[GW2API sharedAPI] fetch:[GW2Recipe class]
              completionBlock:^(id domain) {
                  
                  // ... we'll fetch the first recipe data, partly to verify the services are up, but also to make the
                  // model moderately useful on completion.
                  [[GW2API sharedAPI] fetch:[[GW2Recipe recipes] objectAtIndex:0]
                            completionBlock:^(id domain) {
                                
                                // ... and we'll finish by telling the delegate that our collection has been loaded.
                                completion(GW2APIDomainCollectionRecipes);
                            }];
              }];
}

- (void)fetchCollection_EventsWithCompletionBlock:(GW2APIDomainCollectionCompleted)completion {
    // We're after events, but, we'll start with maps to ensure we have everything we need...
    [[GW2API sharedAPI] fetch:[GW2Map class]
              completionBlock:^(id domain) {
                  
                  // We have maps, let's grab events.
                  [[GW2API sharedAPI] fetch:[GW2Event class]
                            completionBlock:^(id domain) {
                                
                                // ... and we'll finish by telling the delegate that our collection has been loaded.
                                completion(GW2APIDomainCollectionEvents);
                            }];
              }];
}


#pragma mark - Generalised API interfaces -

- (BOOL)objectsHaveDetails:(NSArray *)objects {
    BOOL allFetched = YES;
    for ( id backedObject in objects ) {
        if ( ![backedObject name] ) {
            allFetched = NO;
        }
    }
    return allFetched;
}

- (void)fetch:(id)domain completionBlock:(GW2APIDomainCompleted)completion {
    
    // We've been asked to fetch something from the domain. First of all we need to get a sense of whether it's a singular domain or whether it
    // has children or associated domain objects that also require fetching.
    if ( [domain respondsToSelector:@selector(requiredDomainObjects)] ) {
        
        // So, the domain requires additional domain objects. Let's kick off the fetch for the domain first of all...
        [self fetch:domain completionBlock:completion andRequestSuccessBlock:
         
         ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             [domain parse:JSON];
             
             // ... now that we've fetched the main domain, let's see what additional domain objects we need...
             // ... are they populated already?
             NSArray * requiredObjects = [domain requiredDomainObjects];
             if ( ![self objectsHaveDetails:requiredObjects] ) {
                 
                 // ... so we need to fetch some objects.
                 for ( id requiredDomain in requiredObjects ) {
                     
                     // Kick off a request for each.
                     [self fetch:requiredDomain completionBlock:^(id requiredDomain) {
                         
                         // As we fetch each required object let's see if we satisfy all requirements.
                         if ( [self objectsHaveDetails:requiredObjects] ) {
                             completion(domain);
                         }
                     }];
                 }
             }
             else {
                 completion(domain);
             }
         }];
    }
    else {
        [self fetch:domain completionBlock:completion andRequestSuccessBlock:
         
         ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             [domain parse:JSON];
             
             completion(domain);
         }];
    }
}


- (void)fetch:(id)domain completionBlock:(GW2APIDomainCompleted)completion andRequestSuccessBlock:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success {

    if ( ![domain conformsToProtocol:@protocol(GW2APIServiceBackedObject)] ) {
        [GW2API raiseException:@"GW2API 'fetch:' received a class that does not implement GW2APIServiceBackedObject"
                        format:@"Received: %@", [domain description]];
    }
    
    // Does this endpoint require names?
    GW2APIEndpoint * endpoint = [GW2APIEndpoint generateEndpointForDomain:domain withLanguage:language_ andVersion:version_];
    if ( [endpoint requiresNames] ) {
        
        // It does, so, we're going hit the names endpoint first.
        [self invokeRequest:endpoint.namesEndpoint
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        [domain parseNames:JSON];
                        
                        // ... and now that we have names we'll hit our main data endpoint to populate the domain.
                        [self invokeRequest:endpoint.endpoint
                                    success:success
                                    failure:nil];
                    }
                    failure:nil];
    }
    else {
        // No names, just kick it off.
        [self invokeRequest:endpoint.endpoint
                    success:success
                    failure:nil];
    }
}


- (void)invokeRequest:(NSString *)endpoint
              success:(void (^)(NSURLRequest * request, NSHTTPURLResponse * response, id JSON))success
              failure:(void (^)(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON))failure {
    
    NSLog(@"[GW2API] Calling: %@", endpoint);
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    
    [operation start];
}




+ (GW2API *)sharedAPI {
    static dispatch_once_t pred;
    static GW2API * shared = nil;
    dispatch_once(&pred, ^{
        shared = [[GW2API alloc] init];
    });
    return shared;
}


+ (void)raiseException:(NSString *)message {
    [NSException raise:message format:nil];
}
                 
+ (void)raiseException:(NSString *)message
                format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3) {
    
    va_list args;
    va_start(args, format);
    [NSException raise:message format:format, args];
}

@end
